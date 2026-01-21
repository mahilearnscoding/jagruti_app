import 'package:appwrite/appwrite.dart';
import '../utils/constants.dart';
import 'appwrite_service.dart';

class ProjectService {
  ProjectService._();
  static final ProjectService I = ProjectService._();

  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      // 🕵️ DEBUG: Printing IDs to verify they are loaded correctly
      print("--------------------------------------------------");
      print("🕵️ DEBUG: Checking Connection...");
      print("👉 Database ID: '${Constants.databaseId}'");
      print("👉 Projects Collection ID: '${Constants.colProjects}'");

      // Attempt to fetch documents
      final response = await AppwriteService.I.list(
        collectionId: Constants.colProjects,
      );

      // ✅ SUCCESS: Print how many docs we found
      print("✅ SUCCESS: Appwrite returned ${response.documents.length} projects.");

      if (response.documents.isNotEmpty) {
        print("📄 Data Preview: ${response.documents.first.data}");
      } else {
        print("⚠️ WARNING: List is empty. Check Permissions or 'Row Security'.");
      }
      print("--------------------------------------------------");

      // Convert documents to a list
      return response.documents.map((doc) {
        final data = doc.data;
        // Inject the ID into the data map so the UI can use it
        data['id'] = doc.$id; 
        return data;
      }).toList();
      
    } catch (e) {
  if (e is AppwriteException) {
    print("🆘 APPWRITE ERROR: ${e.code}");
    print("🆘 MESSAGE: ${e.message}");
    print("🆘 RESPONSE: ${e.response}");
  } else {
    print("❌ GENERAL ERROR: $e");
  }
  return [];
}
  }
}