import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../../models/child.dart';
import 'add_child_screen.dart'; // <--- Make sure this file exists!

class ChildListScreen extends StatefulWidget {
  final String projectName;
  final String location;

  const ChildListScreen({
    super.key,
    required this.projectName,
    required this.location,
  });

  @override
  State<ChildListScreen> createState() => _ChildListScreenState();
}

class _ChildListScreenState extends State<ChildListScreen> {
  // 1. APPWRITE CONFIGURATION
  final String databaseId = '696a60cf00151d14bf35'; // Your DB ID
  final String collectionId = 'children'; // Your Collection ID

  late Client client;
  late Databases databases;

  @override
  void initState() {
    super.initState();
    // Initialize Appwrite
    client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('696a5e940026621a01ee'); // Your Project ID
    databases = Databases(client);
  }

  // 2. FETCH DATA FUNCTION
  Future<List<Child>> getChildren() async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
      );

      return response.documents.map((doc) {
        return Child.fromMap(doc.data);
      }).toList();
    } catch (e) {
      print("Error fetching children: $e");
      return []; // Return empty list on error
    }
  }

  // 3. MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Beneficiaries",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              widget.projectName,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),

      // 4. THE LIST
      body: FutureBuilder<List<Child>>(
        future: getChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No children found. Add one!"));
          }

          final children = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (context, index) {
              return _buildBeneficiaryCard(children[index]);
            },
          );
        },
      ),

      // 5. ADD BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF26A69A),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Navigate to Add Screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddChildScreen()),
          );
          // Refresh list if a child was added
          if (result == true) {
            setState(() {});
          }
        },
      ),
    );
  }

  // 6. CARD WIDGET HELPER
  Widget _buildBeneficiaryCard(Child child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE0F2F1),
              child: const Icon(Icons.person_outline, color: Color(0xFF009688)),
            ),
            const SizedBox(width: 16),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${child.name}, ${child.age} yrs",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Guardian: ${child.guardianName}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Text(
                    child.location,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  // Tags
                  Wrap(
                    spacing: 8,
                    children: child.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Color(0xFF00695C),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}