import 'package:flutter/material.dart';
import '../../services/project_service.dart';
import '../children/child_list_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      // Fetch data from Service
      final data = await ProjectService.I.getProjects();
      
      if (mounted) {
        setState(() {
          _projects = data;
          _isLoading = false; // Stop loading on success
        });
      }
    } catch (e) {
      print("Error loading projects: $e");
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading even on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Failed to load projects")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'), 
        backgroundColor: const Color(0xFF26A69A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? const Center(
                  child: Text(
                    "No projects assigned.\nContact your administrator.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];

                    // --- CRITICAL CRASH FIX ---
                    // 1. Get ID safely: Checks for '$id' (Appwrite default) OR 'id' OR empty string
                    final String pId = project['\$id']?.toString() 
                                    ?? project['id']?.toString() 
                                    ?? "";

                    // 2. Get Name safely: If null, defaults to "Unnamed Project"
                    final String pName = project['name']?.toString() ?? "Unnamed Project";
                    
                    // 3. Get Description safely
                    final String pDesc = project['description']?.toString() ?? "Active Program";

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.folder, color: Color(0xFF26A69A)),
                        ),
                        title: Text(
                          pName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(pDesc, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        onTap: () {
                          // Prevent navigation if ID is invalid
                          if (pId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Error: Project ID is missing"))
                            );
                            return;
                          }

                          // Navigate to Child List
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChildListScreen(
                                projectId: pId,
                                projectName: pName,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}