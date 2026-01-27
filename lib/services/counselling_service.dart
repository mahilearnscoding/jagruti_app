import 'package:appwrite/appwrite.dart';
import '../utils/constants.dart';
import 'appwrite_service.dart';

class CounsellingItem {
  final String itemId;
  final String key;
  final String category;
  final String description;
  final String statusType;
  final List<String> options;
  final int displayOrder;

  CounsellingItem({
    required this.itemId,
    required this.key,
    required this.category,
    required this.description,
    required this.statusType,
    required this.options,
    required this.displayOrder,
  });
}

class CounsellingService {
  CounsellingService._();
  static final CounsellingService I = CounsellingService._();

  Future<List<CounsellingItem>> getCounsellingItems(String projectId) async {
    final aw = AppwriteService.I;
    await aw.ensureSession();

    // Get counselling items from the counselling_items table
    final itemsRes = await aw.list(
      collectionId: Constants.colCounsellingItems,
      queries: [
        // Remove all filters to get basic data loading first
        Query.limit(50),
      ],
    );

    List<CounsellingItem> items = [];

    for (var doc in itemsRes.documents) {
      // Parse options if they exist
      List<String> options = [];
      String statusType = (doc.data['status_type'] ?? 'checkbox').toString();

      if (statusType == 'selection' && doc.data['options'] != null) {
        final optionsData = doc.data['options'];
        if (optionsData is List) {
          options = (optionsData as List)
              .map((o) => o.toString())
              .toList();
        }
      } else if (statusType == 'checkbox_na') {
        options = ['ಹೌದು', 'ಇಲ್ಲ', 'ಅನ್ವಯವಾಗುವುದಿಲ್ಲ'];
      } else {
        // Default to Yes/No for checkbox or missing status_type
        options = ['ಹೌದು', 'ಇಲ್ಲ'];
      }

      items.add(
        CounsellingItem(
          itemId: doc.$id,
          key: (doc.data['key'] ?? doc.$id).toString(),
          category: (doc.data['category'] ?? 'General').toString(),
          description: (doc.data['description'] ?? 'Unknown Item').toString(),
          statusType: statusType,
          options: options,
          displayOrder: (doc.data['display_order'] ?? 0) as int,
        ),
      );
    }

    return items;
  }

  Future<String> createCounsellingVisit({
    required String childId,
    required String fieldWorkerId,
    required String projectId,
  }) async {
    final aw = AppwriteService.I;
    await aw.ensureSession();

    final visitData = {
      'child': childId,
      'field_worker': fieldWorkerId,
      // 'project': projectId, // Commented out - causing unknown attribute error
      'visit_date': DateTime.now().toIso8601String(),
      'status': 'in_progress',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final doc = await aw.create(
      collectionId: Constants.colCounsellingVisits,
      documentId: ID.unique(),
      data: visitData,
    );

    return doc.$id;
  }

  Future<void> saveCounsellingResponse({
    required String visitId,
    required String itemId,
    required String status,
    String? comments,
  }) async {
    final aw = AppwriteService.I;
    await aw.ensureSession();

    final responseData = {
      'visit': visitId,
      'item': itemId,
      'status': status,
      'comments': comments ?? '',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Check if response already exists
    final existing = await aw.list(
      collectionId: Constants.colCounsellingResponses,
      queries: [
        Query.equal('visit', visitId),
        Query.equal('item', itemId),
        Query.limit(1),
      ],
    );

    if (existing.documents.isNotEmpty) {
      // Update existing response
      await aw.update(
        collectionId: Constants.colCounsellingResponses,
        documentId: existing.documents.first.$id,
        data: responseData,
      );
    } else {
      // Create new response
      await aw.create(
        collectionId: Constants.colCounsellingResponses,
        documentId: ID.unique(),
        data: responseData,
      );
    }
  }

  Future<void> completeCounsellingVisit(String visitId) async {
    final aw = AppwriteService.I;
    await aw.ensureSession();

    await aw.update(
      collectionId: Constants.colCounsellingVisits,
      documentId: visitId,
      data: {
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<bool> isCounsellingCompleted({
    required String childId,
    required String projectId,
  }) async {
    final aw = AppwriteService.I;
    await aw.ensureSession();

    try {
      final visitsRes = await aw.list(
        collectionId: Constants.colCounsellingVisits,
        queries: [
          Query.equal('child', childId),
          // Query.equal('project', projectId), // Commented out - causing unknown attribute error
          Query.equal('status', 'completed'),
          Query.limit(1),
        ],
      );

      return visitsRes.documents.isNotEmpty;
    } catch (e) {
      print('Error checking counselling completion: $e');
      return false;
    }
  }

  Future<Map<String, String>> getCounsellingResponses(String visitId) async {
    final aw = AppwriteService.I;
    await aw.ensureSession();

    final responsesRes = await aw.list(
      collectionId: Constants.colCounsellingResponses,
      queries: [
        Query.equal('visit', visitId),
      ],
    );

    Map<String, String> responses = {};
    for (var doc in responsesRes.documents) {
      final itemId = aw.relId(doc.data['counselling_item']);
      responses[itemId] = doc.data['response']?.toString() ?? '';
    }

    return responses;
  }
}