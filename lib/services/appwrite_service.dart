import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../utils/constants.dart';

class AppwriteService {
  AppwriteService._();
  static final AppwriteService I = AppwriteService._();

  late final Client client;
  Databases? _db; // Changed from 'late' to nullable to prevent the crash

  // Getter to safely access the database
  Databases get db {
    if (_db == null) {
      init(); // Auto-initialize if it hasn't been yet
    }
    return _db!;
  }

  void init() {
    client = Client()
      ..setEndpoint(Constants.appwriteEndpoint)
      ..setProject(Constants.appwriteProjectId);
    _db = Databases(client);
  }

  // Helper to fix the relationship ID issue
  String? relId(dynamic rel) {
    if (rel == null) return null;
    if (rel is String) return rel;
    if (rel is Map) {
       if (rel['\$id'] != null) return rel['\$id'].toString();
       if (rel[r'$id'] != null) return rel[r'$id'].toString();
    }
    return null;
  }

  Future<models.DocumentList> list({required String collectionId, List<String> queries = const []}) {
    // Uses the safe 'db' getter
    return db.listDocuments(
      databaseId: Constants.databaseId, 
      collectionId: collectionId, 
      queries: queries
    );
  }

  Future<models.Document> get({required String collectionId, required String documentId}) {
    return db.getDocument(
      databaseId: Constants.databaseId, 
      collectionId: collectionId, 
      documentId: documentId
    );
  }

  Future<models.Document> create({required String collectionId, required Map<String, dynamic> data, String? documentId}) {
    return db.createDocument(
      databaseId: Constants.databaseId, 
      collectionId: collectionId, 
      documentId: documentId ?? ID.unique(), 
      data: data
    );
  }
}