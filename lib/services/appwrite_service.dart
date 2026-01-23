import 'dart:developer' as dev;
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../utils/constants.dart';

class AppwriteService {
  AppwriteService._();
  static final AppwriteService I = AppwriteService._();

  late final Client client;
  late final Databases db;
  late final Account account;

  bool _inited = false;

  void init() {
    if (_inited) return;

    client = Client()
      ..setEndpoint(Constants.appwriteEndpoint) // MUST be region endpoint on Appwrite Cloud
      ..setProject(Constants.appwriteProjectId);

    db = Databases(client);
    account = Account(client);

    _inited = true;

    dev.log(
      'Appwrite init: endpoint=${Constants.appwriteEndpoint}, project=${Constants.appwriteProjectId}, db=${Constants.databaseId}',
      name: 'AppwriteService',
    );
  }

  /// Create an anonymous session if not logged in.
  Future<void> ensureSession() async {
  init();
  
  dev.log('Checking session...', name: 'AppwriteService');
  dev.log('Endpoint: ${Constants.appwriteEndpoint}', name: 'AppwriteService');
  dev.log('Project: ${Constants.appwriteProjectId}', name: 'AppwriteService');
  
  try {
    final session = await account.get();
    dev.log('Already logged in: ${session.$id}', name: 'AppwriteService');
  } on AppwriteException catch (e) {
    dev.log(
      'Session check failed: code=${e.code}, type=${e.type}, msg=${e.message}',
      name: 'AppwriteService',
    );

    if (e.code == 401) {
      dev.log('Creating anonymous session...', name: 'AppwriteService');
      try {
        await account.createAnonymousSession();
        dev.log('Anonymous session created successfully', name: 'AppwriteService');
      } catch (innerE) {
        dev.log('Failed to create session: $innerE', name: 'AppwriteService');
        rethrow;
      }
      return;
    }

    dev.log('Already logged in or error: $e', name: 'AppwriteService');
    rethrow;
  }
}

  /// relationship id helper (handles both string and relation object)
  String? relId(dynamic rel) {
    if (rel == null) return null;
    if (rel is String) return rel;
    if (rel is Map) {
      if (rel['\$id'] != null) return rel['\$id'].toString();
      if (rel[r'$id'] != null) return rel[r'$id'].toString();
    }
    return null;
  }

  Future<models.DocumentList> list({
    required String collectionId,
    List<String> queries = const [],
  }) async {
    init();
    return db.listDocuments(
      databaseId: Constants.databaseId,
      collectionId: collectionId,
      queries: queries,
    );
  }

  Future<models.Document> get({
    required String collectionId,
    required String documentId,
  }) async {
    init();
    return db.getDocument(
      databaseId: Constants.databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }

  Future<models.Document> create({
    required String collectionId,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    init();
    return db.createDocument(
      databaseId: Constants.databaseId,
      collectionId: collectionId,
      documentId: documentId ?? ID.unique(),
      data: data,
    );
  }

  Future<models.Document> update({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    init();
    return db.updateDocument(
      databaseId: Constants.databaseId,
      collectionId: collectionId,
      documentId: documentId,
      data: data,
    );
  }
}
