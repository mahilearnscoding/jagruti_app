import 'package:appwrite/appwrite.dart';
import '../utils/constants.dart';
import '../services/appwrite_service.dart';

class CounsellingSeeder {
  final AppwriteService aw;
  final String projectDocId;

  CounsellingSeeder({required this.aw, required this.projectDocId});

  List<String> get _perms => [
    Permission.read(Role.any()),
    Permission.write(Role.any()),
  ];

  static const List<Map<String, dynamic>> counsellingItems = [
    // Session Details Category
    {
      'key': 'session_location',
      'category': 'ಸಮಾಲೋಚನೆ ವಿವರಗಳು',
      'description': 'ಸಮಾಲೋಚನೆ ನಡೆದ ಸ್ಥಳ ದಾಖಲಿಸಿ',
      'status_type': 'selection',
      'options': ['ಮನೆ ಭೇಟಿ', 'ಸಭೆಯ ಸ್ಥಳ', 'ಅಂಗನವಾಡಿ ಕೇಂದ್ರ'],
      'display_order': 1,
    },
    {
      'key': 'session_duration',
      'category': 'ಸಮಾಲೋಚನೆ ವಿವರಗಳು',
      'description': 'ಸಮಾಲೋಚನೆ ಅವಧಿ ದಾಖಲಿಸಿ',
      'status_type': 'selection',
      'options': ['15-30 ನಿಮಿಷಗಳು', '30-45 ನಿಮಿಷಗಳು', '45 ನಿಮಿಷಗಳಿಗಿಂತ ಹೆಚ್ಚು'],
      'display_order': 2,
    },

    // Feeding Frequency & Practices Category
    {
      'key': 'feeding_frequency',
      'category': 'ಆಹಾರ ಆವರ್ತನ ಮತ್ತು ಆಚರಣೆಗಳು',
      'description': 'ದಿನಕ್ಕೆ ಕನಿಷ್ಠ 4 ಬಾರಿ ಆಹಾರ ನೀಡುವುದನ್ನು ಚರ್ಚಿಸಲಾಗಿದೆಯೇ?',
      'status_type': 'checkbox',
      'display_order': 10,
    },
    {
      'key': 'food_consistency',
      'category': 'ಆಹಾರ ಆವರ್ತನ ಮತ್ತು ಆಚರಣೆಗಳು',
      'description': 'ದಪ್ಪ / ಅರೆ-ಘನ ಆಹಾರದ ಸ್ಠಿರತೆಯನ್ನು ಚರ್ಚಿಸಲಾಗಿದೆಯೇ?',
      'status_type': 'checkbox',
      'display_order': 11,
    },
    {
      'key': 'age_appropriate_foods',
      'category': 'ಆಹಾರ ಆವರ್ತನ ಮತ್ತು ಆಚರಣೆಗಳು',
      'description': 'ವಯಸ್ಸಿಗೆ ಸೂಕ್ತವಾದ ಆಹಾರಗಳ ಆಯ್ಕೆ ಬಗ್ಗೆ ಚರ್ಚಿಸಲಾಗಿದೆಯೇ?',
      'status_type': 'checkbox',
      'display_order': 12,
    },
    {
      'key': 'continued_breastfeeding',
      'category': 'ಆಹಾರ ಆವರ್ತನ ಮತ್ತು ಆಚರಣೆಗಳು',
      'description': 'ನಿರಂತರ ಸ್ತನ್ಯಪಾನನ್ನು ಚರ್ಚಿಸಲಾಗಿದೆಯೇ? (ಅನ್ವಯಿಸಿದರೆ)',
      'status_type': 'checkbox_na',
      'display_order': 13,
    },

    // Food Preparation & Portions Category
    {
      'key': 'proper_preparation',
      'category': 'ಆಹಾರ ತಯಾರಿಕೆ ಮತ್ತು ಪ್ರಮಾಣ',
      'description': 'ಸರಿಯಾದ ತಯಾರಿಕೆಯನ್ನು ವಿವರಿಸಲಾಗಿದೆಯೇ?',
      'status_type': 'checkbox',
      'display_order': 20,
    },
    {
      'key': 'portion_per_feed',
      'category': 'ಆಹಾರ ತಯಾರಿಕೆ ಮತ್ತು ಪ್ರಮಾಣ',
      'description': 'ಪ್ರತಿ ಫೀಡ್‌ಗೆ ನೀಡುವ ಪ್ರಮಾಣವನ್ನು ಚರ್ಚಿಸಲಾಗಿದೆಯೇ?',
      'status_type': 'checkbox',
      'display_order': 21,
    },
    {
      'key': 'child_exclusive_use',
      'category': 'ಆಹಾರ ತಯಾರಿಕೆ ಮತ್ತು ಪ್ರಮಾಣ',
      'description': 'ಮಗುವಿಗೆ ಮಾತ್ರ ಬಳಸುವಂತೆ ಒತ್ತು ನೀಡಲಾಗಿದೆಯೇ?',
      'status_type': 'checkbox',
      'display_order': 22,
    },

    // Junk Food & Alternatives Category
    {
      'key': 'junk_food_harms',
      'category': 'ಜಂಕ್ ಫುಡ್ ಮತ್ತು ಪರ್ಯಾಯಗಳು',
      'description': 'ಜಂಕ್ ಫುಡ್‌ನ ಹಾನಿಗಳನ್ನು ವಿವರಿಸಲಾಗಿದೆಯೇ?',
      'status_type': 'checkbox',
      'display_order': 30,
    },
    {
      'key': 'identify_junk_foods',
      'category': 'ಜಂಕ್ ಫುಡ್ ಮತ್ತು ಪರ್ಯಾಯಗಳು',
      'description': 'ಮಗು ಸೇವಿಸುವ ಜಂಕ್ ಫುಡ್‌ಗಳನ್ನು ಗುರುತಿಸಲಾಗಿದೆಯೇ?',
      'status_type': 'checkbox',
      'display_order': 31,
    },
    {
      'key': 'healthy_alternatives',
      'category': 'ಜಂಕ್ ಫುಡ್ ಮತ್ತು ಪರ್ಯಾಯಗಳು',
      'description': 'ಸ್ಥಳೀಯವಾಗಿ ಲಭ್ಯವಿರುವ ಆರೋಗ್ಯಕರ ಬದಲಿಗಳನ್ನು ಸೂಚಿಸಲಾಗಿದೆಯೇ?',
      'status_type': 'checkbox',
      'display_order': 32,
    },

    // Feeding Practices & Interaction Category
    {
      'key': 'attentive_feeding',
      'category': 'ಆಹಾರ ಆಚರಣೆ ಮತ್ತು ಸಂವಹನ',
      'description': 'ಗಮನವಿಟ್ಟು ಮತ್ತು ಸಹನಶೀಲವಾಗಿ ಆಹಾರ ನೀಡಲು ಪ್ರೋತ್ಸಾಹಿಸಲಾಗಿದೆಯೇ?',
      'status_type': 'checkbox',
      'display_order': 40,
    },
    {
      'key': 'talk_during_feeding',
      'category': 'ಆಹಾರ ಆಚರಣೆ ಮತ್ತು ಸಂವಹನ',
      'description': 'ಆಹಾರ ನೀಡುವ ವೇಳೆ ಮಗುವಿನೊಂದಿಗೆ ಮಾತನಾಡಲು / ಹಾಡಲು ಸಲಹೆ ನೀಡಲಾಗಿದೆಯೇ?',
      'status_type': 'checkbox',
      'display_order': 41,
    },
    {
      'key': 'daily_play_interaction',
      'category': 'ಆಹಾರ ಆಚರಣೆ ಮತ್ತು ಸಂವಹನ',
      'description': 'ದೈನಂದಿನ ಆಟ ಮತ್ತು ಸಂವಹನವನ್ನು ಪ್ರೋತ್ಸಾಹಿಸಲಾಗಿದೆಯೇ?',
      'status_type': 'checkbox',
      'display_order': 42,
    },
  ];

  Future<void> seedCounselling() async {
    print('🌱 CounsellingSeeder: start (projectDocId=$projectDocId)');

    int displayOrder = 1;
    for (var item in counsellingItems) {
      await _upsertCounsellingItem(item, displayOrder: displayOrder);
      displayOrder++;
    }

    print('CounsellingSeeder: done');
  }

  Future<void> _upsertCounsellingItem(
    Map<String, dynamic> item, {
    required int displayOrder,
  }) async {
    final key = item['key'] as String;

    // Check if counselling item already exists
    final existing = await aw.list(
      collectionId: Constants.colCounsellingItems,
      queries: [
        Query.equal('key', key),
        Query.equal('project', projectDocId),
        Query.limit(1),
      ],
    );

    Map<String, dynamic> itemData = {
      'key': key,
      'project': projectDocId,
      'category': item['category'] ?? '',
      'description': item['description'] ?? '',
      'status_type': item['status_type'] ?? 'checkbox',
      'display_order': displayOrder,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Add options if they exist
    if (item['options'] != null) {
      itemData['options'] = item['options'];
    }

    if (existing.documents.isNotEmpty) {
      // Update existing
      await aw.update(
        collectionId: Constants.colCounsellingItems,
        documentId: existing.documents.first.$id,
        data: itemData,
        permissions: _perms,
      );
      print('Updated counselling item: $key');
    } else {
      // Create new
      await aw.create(
        collectionId: Constants.colCounsellingItems,
        documentId: ID.unique(),
        data: itemData,
        permissions: _perms,
      );
      print('Created counselling item: $key');
    }
  }
}
