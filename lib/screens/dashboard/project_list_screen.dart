import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../children/child_list_screen.dart'; // <--- IMPORTANT: Ensure this import is here

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DUMMY DATA
    final List<Map<String, dynamic>> projects = [
      {
        "title": "Bangalore Urban Health Initiative",
        "location": "Bangalore",
        "count": 45,
      },
      {
        "title": "Mysore Child Nutrition Program",
        "location": "Mysore",
        "count": 32,
      },
      {
        "title": "Hubli Community Wellness",
        "location": "Hubli",
        "count": 28,
      },
      {
        "title": "Mangalore Coastal Health",
        "location": "Mangalore",
        "count": 19,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Projects", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)
            ),
            Text(
              "Select a project to view beneficiaries", 
              style: TextStyle(fontSize: 14, color: Colors.white70)
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const LoginScreen())
              );
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1), // Light Teal background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder_open, color: Color(0xFF009688)),
              ),
              title: Text(
                project['title'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(project['location'], style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "${project['count']} Children", 
                        style: const TextStyle(fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              // THE NAVIGATION LOGIC
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildListScreen(
                      projectName: project['title'],
                      location: project['location'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF009688),
        child: const Icon(Icons.help_outline, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}