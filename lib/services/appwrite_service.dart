import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../utils/constants.dart';

class AppwriteService {
  AppwriteService._();
  static final AppwriteService I = AppwriteService._();

  late final Client client;
  late final Databases db;

  void init() {
    client = Client()
      ..setEndpoint(Constants.appwriteEndpoint)
      ..setProject(Constants.appwriteProjectId);
    db = Databases(client);
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
    return db.listDocuments(databaseId: Constants.databaseId, collectionId: collectionId, queries: queries);
  }

  Future<models.Document> get({required String collectionId, required String documentId}) {
    return db.getDocument(databaseId: Constants.databaseId, collectionId: collectionId, documentId: documentId);
  }

  Future<models.Document> create({required String collectionId, required Map<String, dynamic> data, String? documentId}) {
    return db.createDocument(databaseId: Constants.databaseId, collectionId: collectionId, documentId: documentId ?? ID.unique(), data: data);
  }
}