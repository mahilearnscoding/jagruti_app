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

  static const List<Map<String, dynamic>> counsellingQuestions = [
    // COUNSELLING QUESTIONS SECTION
    {
      'key': 'kn_counsel_q01',
      'text': 'ತಾಯಿಯ ಹೆಸರು:',
      'type': 'text',
      'is_required': true,
    },
    {
      'key': 'kn_counsel_q02',
      'text': 'ಮಗುವಿನ ಹೆಸರು:',
      'type': 'text',
      'is_required': true,
    },
    {
      'key': 'kn_counsel_q03',
      'text': 'ಮಗುವಿನ ವಯಸ್ಸು ಗುಂಪು:',
      'type': 'single_choice',
      'is_required': true,
      'options': ['6–35 ತಿಂಗಳುಗಳು', '35–59 ತಿಂಗಳುಗಳು'],
    },
    {
      'key': 'kn_counsel_q04',
      'text': 'ಪೌಷ್ಠಿಕಾಂಶದ ಸ್ಥಿತಿ:',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಸಾಮಾನ್ಯ',
        'MAM (ಮಧ್ಯಮ ಅಪೌಷ್ಟಿಕತೆ)',
        'SAM (ತೀವ್ರ ಅಪೌಷ್ಟಿಕತೆ)',
      ],
    },
    {
      'key': 'kn_counsel_q05',
      'text': 'ಸಮಾಲೋಚನೆ ನಡೆದ ಸ್ಥಳ:',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಮನೆ ಭೇಟಿ', 'ಸಭೆಯ ಸ್ಥಳ'],
    },
    {
      'key': 'kn_counsel_q06',
      'text': 'ದಿನಕ್ಕೆ ಕನಿಷ್ಠ 4 ಬಾರಿ ಆಹಾರ ನೀಡುವುದನ್ನು ಚರ್ಚಿಸಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q07',
      'text': 'ದಪ್ಪ / ಅರೆ-ಘನ ಆಹಾರದ ಸ್ಥಿರತೆಯನ್ನು ಚರ್ಚಿಸಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q08',
      'text': 'ವಯಸ್ಸಿಗೆ ಸೂಕ್ತವಾದ ಆಹಾರಗಳ ಆಯ್ಕೆ ಬಗ್ಗೆ ಚರ್ಚಿಸಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q09',
      'text': 'ನಿರಂತರ ಸ್ತನ್ಯಪಾನನ್ನು ಚರ್ಚಿಸಲಾಗಿದೆಯೇ? (ಅನ್ವಯಿಸಿದರೆ)',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ', 'ಅನ್ವಯವಾಗುವುದಿಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q10',
      'text': 'ಸರಿಯಾದ ತಯಾರಿಕೆಯನ್ನು ವಿವರಿಸಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q11',
      'text': 'ಪ್ರತಿ ಫೀಡ್‌ಗೆ ನೀಡುವ ಪ್ರಮಾಣವನ್ನು ಚರ್ಚಿಸಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q12',
      'text': 'ಮಗುವಿಗೆ ಮಾತ್ರ ಬಳಸುವಂತೆ ಒತ್ತು ನೀಡಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q13',
      'text': 'ಜಂಕ್ ಫುಡ್‌ನ ಹಾನಿಗಳನ್ನು ವಿವರಿಸಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q14',
      'text': 'ಮಗು ಸೇವಿಸುವ ಜಂಕ್ ಫುಡ್‌ಗಳನ್ನು ಗುರುತಿಸಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q15',
      'text': 'ಸ್ಥಳೀಯವಾಗಿ ಲಭ್ಯವಿರುವ ಆರೋಗ್ಯಕರ ಬದಲಿಗಳನ್ನು ಸೂಚಿಸಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q16',
      'text': 'ಗಮನವಿಟ್ಟು ಮತ್ತು ಸಹನಶೀಲವಾಗಿ ಆಹಾರ ನೀಡಲು ಪ್ರೋತ್ಸಾಹಿಸಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q17',
      'text': 'ಆಹಾರ ನೀಡುವ ವೇಳೆ ಮಗುವಿನೊಂದಿಗೆ ಮಾತನಾಡಲು / ಹಾಡಲು ಸಲಹೆ ನೀಡಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q18',
      'text': 'ದೈನಂದಿನ ಆಟ ಮತ್ತು ಸಂವಹನವನ್ನು ಪ್ರೋತ್ಸಾಹಿಸಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_counsel_q19',
      'text': 'ಸಮಾಲೋಚನೆ ಅವಧಿ:',
      'type': 'single_choice',
      'is_required': true,
      'options': ['5 ನಿಮಿಷಕ್ಕಿಂತ ಕಡಿಮೆ', '5–10 ನಿಮಿಷ'],
    },
    {
      'key': 'kn_counsel_q20',
      'text': 'ಕ್ಷೇತ್ರ ಸಿಬ್ಬಂದಿಯ ಹೆಸರು:',
      'type': 'text',
      'is_required': true,
    },
  ];

  Future<void> seedCounselling() async {
    int displayOrder = 1;

    print("🌱 CounsellingSeeder: start (projectDocId=$projectDocId)");

    for (final q in counsellingQuestions) {
      final questionId = await _upsertQuestion(q);
      await _upsertOptions(questionId, q);
      await _upsertProjectLink(questionId, q, displayOrder: displayOrder++);
    }

    print("CounsellingSeeder: done");
  }

  Future<String> _upsertQuestion(Map<String, dynamic> q) async {
    final key = q['key'] as String;

    final existing = await aw.list(
      collectionId: Constants.colQuestions,
      queries: [Query.equal('question_key', key), Query.limit(1)],
    );

    if (existing.documents.isNotEmpty) {
      return existing.documents.first.$id;
    }

    final created = await aw.create(
      collectionId: Constants.colQuestions,
      permissions: _perms,
      data: {
        'question_key': key,
        'question_text': q['text'],
        'answer_type': q['type'],
        'is_anthropometric': q['is_anthropometric'] ?? false,
        'is_active': true,
      },
    );

    return created.$id;
  }

  Future<void> _upsertOptions(String questionId, Map<String, dynamic> q) async {
    final opts = (q['options'] as List?)?.cast<String>() ?? const <String>[];
    if (opts.isEmpty) return;

    final qKey = q['key'] as String;

    for (int i = 0; i < opts.length; i++) {
      final label = opts[i].trim();
      final value = '${qKey}_opt_${i + 1}';

      final existing = await aw.list(
        collectionId: Constants.colQuestionOptions,
        queries: [
          Query.equal('question', questionId),
          Query.equal('option_value', value),
          Query.limit(1),
        ],
      );

      if (existing.documents.isNotEmpty) continue;

      await aw.create(
        collectionId: Constants.colQuestionOptions,
        permissions: _perms,
        data: {
          'question': questionId,
          'option_value': value,
          'option_label': label,
          'display_order': i + 1,
        },
      );
    }
  }

  Future<void> _upsertProjectLink(
    String questionId,
    Map<String, dynamic> q, {
    required int displayOrder,
  }) async {
    final phase = Constants.phaseCounselling;

    final existing = await aw.list(
      collectionId: Constants.colProjectQuestions,
      queries: [
        Query.equal('project', projectDocId),
        Query.equal('question', questionId),
        Query.equal('phase', phase),
        Query.limit(1),
      ],
    );

    if (existing.documents.isNotEmpty) return;

    await aw.create(
      collectionId: Constants.colProjectQuestions,
      permissions: _perms,
      data: {
        'project': projectDocId,
        'question': questionId,
        'phase': phase,
        'display_order': displayOrder,
        'is_required': q['is_required'] ?? true,
      },
    );
  }
}
