import 'package:flutter/material.dart';
import '../../services/child_service.dart';
import 'child_registration_screen.dart';
import 'child_profile_screen.dart';

class ChildListScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ChildListScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ChildListScreen> createState() => _ChildListScreenState();
}

class _ChildListScreenState extends State<ChildListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _children = [];
  List<Map<String, dynamic>> _filteredChildren = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChildren(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredChildren = _children;
      } else {
        _filteredChildren = _children.where((child) {
          final name = (child['name'] ?? '').toString().toLowerCase();
          final guardian = (child['guardian_name'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || guardian.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _loadChildren() async {
    try {
      final data = await ChildService.I.listChildren(widget.projectId);
      if (mounted) {
        setState(() {
          _children = data;
          _filteredChildren = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading children: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToAddChild() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChildRegistrationScreen(),
      ),
    );

    // If we return 'true' (meaning a child was added), refresh the list
    if (result == true) {
      _isLoading = true; // Show loader immediately
      setState(() {});
      await _loadChildren();
    }
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF26A69A);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        backgroundColor: teal,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: teal,
        onPressed: _navigateToAddChild,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _filterChildren,
              decoration: InputDecoration(
                hintText: 'Search by name or guardian...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterChildren('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Children List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredChildren.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? "No children match your search."
                              : "No beneficiaries added yet.\nTap + to add one.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredChildren.length,
                        itemBuilder: (context, index) {
                          final child = _filteredChildren[index];
                          final counsellingStatus = child['counsellingStatus'] ?? 'pending';
                          final isCounsellingDone = counsellingStatus == 'submitted' || counsellingStatus == 'completed';
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal.shade100,
                                child: Text(
                                  (child['name'] ?? 'U')[0].toString().toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                                ),
                              ),
                              title: Text(
                                child['name'] ?? 'Unknown Name',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Guardian: ${child['guardian_name'] ?? 'N/A'}"),
                                  const SizedBox(height: 4),
                                  if (isCounsellingDone)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green),
                                      ),
                                      child: const Text(
                                        'Counselling Done',
                                        style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChildProfileScreen(
                                      projectId: widget.projectId,
                                      childId: child['id'] ?? '',
                                      childName: child['name'] ?? 'Unknown',
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}