import 'package:appwrite/appwrite.dart';
import '../utils/constants.dart';
import 'appwrite_service.dart';

class ProjectService {
  ProjectService._();
  static final ProjectService I = ProjectService._();

  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final response = await AppwriteService.I.list(
        collectionId: Constants.colProjects,
      );

      // Convert documents to a nice list of data
      return response.documents.map((doc) {
        final data = doc.data;
        // Inject the ID into the data map so the UI can use it
        data['id'] = doc.$id; 
        return data;
      }).toList();
      
    } catch (e) {
      print("Error fetching projects: $e");
      // Return empty list instead of crashing
      return [];
    }
  }
}