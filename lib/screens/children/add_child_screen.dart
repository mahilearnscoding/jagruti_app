import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  // 1. SETUP APPWRITE
  final String databaseId = '696a60cf00151d14bf35';  // Ensure this matches your DB ID
  final String collectionId = 'children';  // As per your screenshot
  late Client client;
  late Databases databases;

  // 2. FORM CONTROLLERS
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _guardianController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('696a5e940026621a01ee'); // Your Project ID
    databases = Databases(client);
  }

  // 3. SAVE FUNCTION
  Future<void> _saveChild() async {
    if (_nameController.text.isEmpty || _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Age are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(), // Auto-generate ID
        data: {
          'name': _nameController.text,
          'age': int.parse(_ageController.text), // Convert text to number
          'guardian_name': _guardianController.text,
          'location': _locationController.text,
          'tags': [], // Empty list for now
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Beneficiary Added Successfully!')),
        );
        Navigator.pop(context, true); // Go back and refresh list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Beneficiary"),
        backgroundColor: const Color(0xFF26A69A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Child Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _guardianController,
                decoration: const InputDecoration(labelText: "Guardian Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location / Address", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
                  onPressed: _isLoading ? null : _saveChild,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SAVE BENEFICIARY", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}