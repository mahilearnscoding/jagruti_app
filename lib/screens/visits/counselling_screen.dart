import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/counselling_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/sync_manager.dart';
import '../../services/location_service.dart';
import '../../services/camera_service.dart';

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
  
  // Location and Photo state
  bool _hasLocation = false;
  bool _hasPhoto = false;
  bool _isCapturingLocation = false;
  bool _isCapturingPhoto = false;
  String? _photoUrl;

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

  Future<void> _captureLocation() async {
    setState(() => _isCapturingLocation = true);
    
    try {
      final position = await LocationService.I.getCurrentLocation();
      setState(() {
        _hasLocation = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location captured: ${position?.latitude.toStringAsFixed(6) ?? '0.0'}, ${position?.longitude.toStringAsFixed(6) ?? '0.0'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isCapturingLocation = false);
    }
  }

  Future<void> _capturePhoto() async {
    setState(() => _isCapturingPhoto = true);
    
    try {
      final result = await CameraService.I.captureGeotaggedPhotoWithLocation();
      setState(() {
        _hasPhoto = result['photoUrl'] != null;
        _photoUrl = result['photoUrl'];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_hasPhoto ? 'Geotagged photo captured successfully!' : 'Photo capture failed'),
            backgroundColor: _hasPhoto ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _hasPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo capture failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isCapturingPhoto = false);
    }
  }

  Future<void> _loadCounsellingItems() async {
    try {
      setState(() => _isLoading = true);

      List<CounsellingItem> items;
      
      try {
        items = await CounsellingService.I.getCounsellingItems(widget.projectId);
        print('✅ Loaded ${items.length} counselling items from server');
      } catch (e) {
        print('❌ Failed to load from server: $e');
        // For demo, create some hardcoded items
        items = [
          CounsellingItem(
            itemId: 'demo1',
            key: 'home_environment',
            category: 'ಸಾಮಾನ್ಯ',
            description: 'ಮನೆಯ ಮುಖ್ಯಸ್ಥರ ಹೆಸರು:',
            statusType: 'checkbox',
            options: ['ಹೌದು', 'ಇಲ್ಲ'],
            displayOrder: 1,
          ),
          CounsellingItem(
            itemId: 'demo2',
            key: 'child_safety', 
            category: 'ಸಾಮಾನ್ಯ',
            description: 'ಮಗುವಿನ ಸುರಕ್ಷತೆಯ ಪರಿಸ್ಥಿತಿ',
            statusType: 'checkbox',
            options: ['ಹೌದು', 'ಇಲ್ಲ'],
            displayOrder: 2,
          ),
        ];
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Using demo data - database connection failed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      
      // Create a visit
      final fwId = LocalStorageService.I.fieldWorkerId ?? 'unknown_worker';
      
      try {
        final visitId = await CounsellingService.I.createCounsellingVisit(
          childId: widget.childId,
          fieldWorkerId: fwId,
          projectId: widget.projectId,
        );
        _visitId = visitId;
      } catch (e) {
        print('❌ Failed to create visit: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create counselling visit: $e')),
          );
          Navigator.pop(context);
        }
        return;
      }

      // Initialize controllers for comments
      _commentControllers.clear();
      for (var item in items) {
        _commentControllers[item.itemId] = TextEditingController();
      }

      _items = items;

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
    // Check if photo and location are captured
    if (!_hasPhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture a geotagged photo before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_hasLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture location before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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

      // Try to sync (don't fail if sync fails)
      try {
        await SyncManager.I.trySync();
      } catch (syncError) {
        print('⚠️ Sync failed (will retry later): $syncError');
      }

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
                        
                        // Location and Photo Capture Section - At the very end of scrollable content
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Required before submission',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  // Location capture button
                                  Expanded(
                                    child: Container(
                                      height: 45,
                                      margin: const EdgeInsets.only(right: 8),
                                      child: ElevatedButton.icon(
                                        onPressed: _isCapturingLocation ? null : _captureLocation,
                                        icon: _isCapturingLocation
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                              )
                                            : Icon(
                                                _hasLocation ? Icons.check_circle : Icons.location_on,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                        label: Text(
                                          _hasLocation ? 'Located ✓' : 'Location',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _hasLocation ? Colors.green : Colors.blue,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Photo capture button
                                  Expanded(
                                    child: Container(
                                      height: 45,
                                      margin: const EdgeInsets.only(left: 8),
                                      child: ElevatedButton.icon(
                                        onPressed: _isCapturingPhoto ? null : _capturePhoto,
                                        icon: _isCapturingPhoto
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                              )
                                            : Icon(
                                                _hasPhoto ? Icons.check_circle : Icons.camera_alt,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                        label: Text(
                                          _hasPhoto ? 'Photo ✓' : 'Photo',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _hasPhoto ? Colors.green : const Color(0xFF26A69A),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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