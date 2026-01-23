import 'package:flutter/material.dart';
import '../../services/child_service.dart';
import 'add_child_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final data = await ChildService.I.listChildren(widget.projectId);
      if (mounted) {
        setState(() {
          _children = data;
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
    // FIX: Passing the required projectId and projectName to the next screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddChildScreen(
          projectId: widget.projectId,
          projectName: widget.projectName,
        ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        backgroundColor: const Color(0xFF26A69A),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF26A69A),
        onPressed: _navigateToAddChild,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _children.isEmpty
              ? const Center(
                  child: Text(
                    "No beneficiaries added yet.\nTap + to add one.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _children.length,
                  itemBuilder: (context, index) {
                    final child = _children[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Text(
                            (child['name'] ?? 'U')[0].toString().toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          child['name'] ?? 'Unknown Name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Guardian: ${child['guardian_name'] ?? 'N/A'}",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Placeholder for future Profile/Edit Screen
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Profile View Coming Soon")));
                        },
                      ),
                    );
                  },
                ),
    );
  }
}