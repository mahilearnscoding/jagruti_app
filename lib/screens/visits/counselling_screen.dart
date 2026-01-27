import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/counselling_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/sync_manager.dart';

class CounsellingScreen extends StatefulWidget {
  final String projectId;
  final String childId;
  final String childName;

  const CounsellingScreen({
    super.key,
    required this.projectId,
    required this.childId,
    required this.childName,
  });

  @override
  State<CounsellingScreen> createState() => _CounsellingScreenState();
}

class _CounsellingScreenState extends State<CounsellingScreen> {
  List<CounsellingItem> _items = [];
  Map<String, String> _responses = {}; // itemId -> status
  Map<String, TextEditingController> _commentControllers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _visitId;
  Map<String, List<CounsellingItem>> _itemsByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadCounsellingItems();
  }

  @override
  void dispose() {
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCounsellingItems() async {
    try {
      setState(() => _isLoading = true);

      final items = await CounsellingService.I.getCounsellingItems(widget.projectId);
      
      // Create a visit
      final fwId = LocalStorageService.I.fieldWorkerId ?? 'unknown_worker';
      final visitId = await CounsellingService.I.createCounsellingVisit(
        childId: widget.childId,
        fieldWorkerId: fwId,
        projectId: widget.projectId,
      );

      // Initialize controllers for comments
      _commentControllers.clear();
      for (var item in items) {
        _commentControllers[item.itemId] = TextEditingController();
      }

      // Group items by category
      _itemsByCategory.clear();
      for (var item in items) {
        if (!_itemsByCategory.containsKey(item.category)) {
          _itemsByCategory[item.category] = [];
        }
        _itemsByCategory[item.category]!.add(item);
      }

      setState(() {
        _items = items;
        _visitId = visitId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading counselling items: $e')),
        );
      }
    }
  }

  Future<void> _submitCounselling() async {
    setState(() => _isSubmitting = true);

    try {
      // Save all responses
      for (var entry in _responses.entries) {
        if (entry.value.isNotEmpty) {
          final comments = _commentControllers[entry.key]?.text ?? '';
          await CounsellingService.I.saveCounsellingResponse(
            visitId: _visitId!,
            itemId: entry.key,
            status: entry.value,
            comments: comments.isNotEmpty ? comments : null,
          );
        }
      }

      // Complete the visit
      await CounsellingService.I.completeCounsellingVisit(_visitId!);

      // Update local child status
      final box = Hive.box('children_local');
      final childData = box.get(widget.childId) ?? {};
      childData['counsellingStatus'] = 'submitted';
      box.put(widget.childId, childData);

      // Try to sync
      await SyncManager.I.trySync();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Counselling submitted successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting counselling: $e')),
        );
      }
    }
  }

  Widget _buildChecklistItem(CounsellingItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            
            // Status selection based on type
            if (item.statusType == 'selection') ..._buildSelectionOptions(item)
            else ..._buildCheckboxOptions(item),
            
            const SizedBox(height: 8),
            
            // Comments field
            TextField(
              controller: _commentControllers[item.itemId],
              decoration: const InputDecoration(
                labelText: 'Comments (optional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildSelectionOptions(CounsellingItem item) {
    return [
      Wrap(
        children: item.options.map((option) => 
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option),
              selected: _responses[item.itemId] == option,
              onSelected: (selected) {
                setState(() {
                  _responses[item.itemId] = selected ? option : '';
                });
              },
            ),
          ),
        ).toList(),
      ),
    ];
  }
  
  List<Widget> _buildCheckboxOptions(CounsellingItem item) {
    return item.options.map((option) => 
      RadioListTile<String>(
        dense: true,
        title: Text(option),
        value: option,
        groupValue: _responses[item.itemId],
        onChanged: (value) {
          setState(() {
            _responses[item.itemId] = value ?? '';
          });
        },
      ),
    ).toList();
  }
  
  Widget _buildCategorySection(String category, List<CounsellingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            category,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ...items.map((item) => _buildChecklistItem(item)),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF26A69A);

    return Scaffold(
      appBar: AppBar(
        title: Text('Counselling: ${widget.childName}'),
        backgroundColor: teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display items grouped by category
                        for (var categoryEntry in _itemsByCategory.entries)
                          _buildCategorySection(categoryEntry.key, categoryEntry.value),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal,
                      ),
                      onPressed: _isSubmitting ? null : _submitCounselling,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Submit Counselling',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}