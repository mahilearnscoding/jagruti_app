import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../utils/constants.dart';

class AppwriteService {
  AppwriteService._();
  static final AppwriteService I = AppwriteService._();

  late final Client _client;
  late final Account _account;
  late final Databases _db;

  bool _inited = false;

  void init() {
    if (_inited) return;

    _client = Client()
        .setEndpoint(Constants.appwriteEndpoint)
        .setProject(Constants.appwriteProjectId);

    // If you are using Appwrite Cloud, this is safe to keep OFF.
    // If you're on self-hosted with self-signed certs, set true.
    _client.setSelfSigned(status: true);

    _account = Account(_client);
    _db = Databases(_client);

    _inited = true;
  }

  Client get client => _client;
  Account get account => _account;

  Future<void> ensureSession() async {
    if (!_inited) {
      init();
    }

    try {
      await _account.get();
      print("✅ Using existing session");
    } catch (_) {
      // Force login as seeder for database operations
      try {
        // Clear any existing session first
        try {
          await _account.deleteSession(sessionId: 'current');
        } catch (_) {}
        
        await _account.createEmailPasswordSession(
          email: 'seeder@jagruti.dev',
          password: 'jagruti123',
        );
        print("✅ Logged in as seeder account for database operations");
      } catch (e) {
        print("❌ Seeder login failed: $e");
        // Try creating seeder account if it doesn't exist
        try {
          await _account.create(
            userId: 'seeder001',
            email: 'seeder@jagruti.dev',
            password: 'jagruti123',
            name: 'Seeder Account',
          );
          await _account.createEmailPasswordSession(
            email: 'seeder@jagruti.dev',
            password: 'jagruti123',
          );
          print("✅ Created and logged in as seeder account");
        } catch (e2) {
          print("❌ Failed to create seeder account: $e2");
          throw Exception('Authentication failed: Cannot access database without proper permissions');
        }
      }
    }
  }

  /// Relationship values sometimes come as:
  /// - "docId"
  /// - {"$id": "docId", ...}
  /// - list of maps
  String relId(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map && value.containsKey('\$id')) {
      return value['\$id']?.toString() ?? '';
    }
    return value.toString();
  }

  // ---------- DB wrappers ----------

  Future<models.DocumentList> list({
    required String collectionId,
    List<String>? queries,
  }) {
    return _db.listDocuments(
      databaseId: Constants.databaseId,
      collectionId: collectionId,
      queries: queries,
    );
  }

  Future<models.Document> get({
    required String collectionId,
    required String documentId,
    List<String>? queries,
  }) {
    return _db.getDocument(
      databaseId: Constants.databaseId,
      collectionId: collectionId,
      documentId: documentId,
      queries: queries,
    );
  }

  Future<models.Document> create({
    required String collectionId,
    required Map<String, dynamic> data,
    String? documentId,
    List<String>? permissions,
  }) {
    final id = documentId ?? ID.unique(); // <-- FIX: not a default param
    return _db.createDocument(
      databaseId: Constants.databaseId,
      collectionId: collectionId,
      documentId: id,
      data: data,
      permissions: permissions,
    );
  }

  Future<models.Document> update({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
    List<String>? permissions,
  }) {
    return _db.updateDocument(
      databaseId: Constants.databaseId,
      collectionId: collectionId,
      documentId: documentId,
      data: data,
      permissions: permissions,
    );
  }

  Future<void> delete({
    required String collectionId,
    required String documentId,
  }) {
    return _db.deleteDocument(
      databaseId: Constants.databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }
}
