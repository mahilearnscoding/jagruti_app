import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../children/child_list_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _projects = [];
  String _debugMessage = "Initializing...";

  // --- 1. HARDCODED CONFIGURATION (Matches your screenshots) ---
  final String projectId = '696a5e940026621a01ee'; // From your screenshot
  final String databaseId = '696a60cf00151d14bf35'; // From your screenshot
  final String collectionId = 'projects'; // From the pill in your screenshot

  @override
  void initState() {
    super.initState();
    _directAppwriteFetch();
  }

  // --- 2. DIRECT FETCH FUNCTION (Bypasses Service/Constants) ---
  Future<void> _directAppwriteFetch() async {
    setState(() => _debugMessage = "Connecting to Appwrite...");

    try {
      // Setup Client manually
      final client = Client()
          .setEndpoint('https://cloud.appwrite.io/v1')
          .setProject(projectId);

      final databases = Databases(client);

      // Fetch Documents
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
      );

      // Success!
      if (mounted) {
        setState(() {
          _projects = response.documents.map((doc) {
            final data = doc.data;
            data['id'] = doc.$id; // Save the ID
            return data;
          }).toList();
          _isLoading = false;
          _debugMessage = "Found ${response.documents.length} projects";
        });

        // Show a popup on the screen so you can see it worked
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ SUCCESS: Found ${response.documents.length} projects!"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Error Handling
      print("❌ ERROR: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _debugMessage = "Error: $e";
        });
        
        // Show the error on screen
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Connection Error"),
            content: Text("Could not fetch data.\n\nError: $e"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
            ],
          ),
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_debugMessage), // Shows what the app is doing
                ],
              ),
            )
          : _projects.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange),
                        const SizedBox(height: 10),
                        const Text(
                          "No projects found.",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Debug Info:\n$_debugMessage\n\nDB: $databaseId\nCol: $collectionId",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _directAppwriteFetch,
                          child: const Text("Retry Connection"),
                        )
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    final pName = project['name'] ?? "Unnamed Project";
                    final pDesc = project['description'] ?? "No description";
                    final pId = project['id'];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.folder, color: Color(0xFF26A69A)),
                        title: Text(pName),
                        subtitle: Text(pDesc),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {
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