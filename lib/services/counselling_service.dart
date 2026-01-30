import 'package:appwrite/appwrite.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
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
    // Use local-first approach like child service
    final visitId = const Uuid().v4();
    final box = Hive.box('counselling_visits_local');
    
    final visitData = {
      'id': visitId,
      'child': childId,
      'field_worker': fieldWorkerId,
      'project': projectId,
      'visit_date': DateTime.now().toIso8601String(),
      'status': 'in_progress',
      'synced': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    // Save locally first
    box.put(visitId, visitData);
    print('✅ Created counselling visit locally: $visitId');
    
    return visitId;
  }

  Future<void> saveCounsellingResponse({
    required String visitId,
    required String itemId,
    required String status,
    String? comments,
  }) async {
    // Use local-first approach
    final box = Hive.box('counselling_responses_local');
    final responseId = '${visitId}_$itemId'; // Composite key

    // Map user responses to database enum values
    String dbStatus;
    switch (status) {
      case 'ಹೌದು': // Yes
        dbStatus = 'already_followed';
        break;
      case 'ಇಲ್ಲ': // No  
        dbStatus = 'advised';
        break;
      case 'ಅನ್ವಯವಾಗುವುದಿಲ್ಲ': // Not applicable
        dbStatus = 'not_applicable';
        break;
      default:
        dbStatus = 'advised'; // Default fallback
    }

    final responseData = {
      'id': responseId,
      'counsellin_visit': visitId,
      'counselling_item': itemId,
      'status': dbStatus,
      'comments': comments ?? '',
      'synced': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Save or update locally
    box.put(responseId, responseData);
    print('✅ Saved counselling response locally: $responseId');
  }

  Future<void> completeCounsellingVisit(String visitId) async {
    // Use local-first approach
    final box = Hive.box('counselling_visits_local');
    final existing = box.get(visitId);
    if (existing != null) {
      final updated = Map<String, dynamic>.from(existing);
      updated['status'] = 'completed';
      updated['notes'] = 'Counselling visit completed';
      updated['completed_at'] = DateTime.now().toIso8601String();
      updated['synced'] = false;
      box.put(visitId, updated);
    }
    print('✅ Counselling visit completed locally: $visitId');
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
        Query.equal('counsellin_visit', visitId),
      ],
    );

    Map<String, String> responses = {};
    for (var doc in responsesRes.documents) {
      final itemId = aw.relId(doc.data['counselling_item']);
      responses[itemId] = doc.data['status']?.toString() ?? '';  // Use 'status' field
    }

    return responses;
  }
}