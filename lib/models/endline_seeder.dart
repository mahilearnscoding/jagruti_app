import 'package:appwrite/appwrite.dart';
import '../utils/constants.dart';
import '../services/appwrite_service.dart';

class EndlineSeeder {
  final AppwriteService aw;
  final String projectDocId;

  EndlineSeeder({required this.aw, required this.projectDocId});

  List<String> get _perms => [
    Permission.read(Role.any()),
    Permission.write(Role.any()),
  ];

  static const List<Map<String, dynamic>> endlineQuestions = [
    // ENDLINE QUESTIONS SECTION (Similar structure to baseline, 56 questions)
    {
      'key': 'kn_endline_q01',
      'text': 'ಮನೆಯ ಮುಖ್ಯಸ್ಥರ ಹೆಸರು:',
      'type': 'text',
      'is_required': true,
    },
    {
      'key': 'kn_endline_q02',
      'text': 'ಮನೆಯ ಮುಖ್ಯಸ್ಥರ ಲಿಂಗ:',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಪುರುಷ', 'ಮಹಿಳೆ', 'ಇತರೆ'],
    },
    {
      'key': 'kn_endline_q03',
      'text': 'ಮನೆಯಲ್ಲಿರುವ ಒಟ್ಟು ಸದಸ್ಯರ ಸಂಖ್ಯೆ:',
      'type': 'single_choice',
      'is_required': true,
      'options': ['1–3', '4–5', '6–7', '8 ಅಥವಾ ಹೆಚ್ಚು'],
    },
    {
      'key': 'kn_endline_q04',
      'text': 'ತಾಯಿಯ ಹೆಸರು:',
      'type': 'text',
      'is_required': true,
    },
    {
      'key': 'kn_endline_q05',
      'text': 'ತಾಯಿಯ ವಯಸ್ಸು (ಪೂರ್ಣಗೊಂಡ ವರ್ಷಗಳಲ್ಲಿ):',
      'type': 'number',
      'is_required': true,
    },
    {
      'key': 'kn_endline_q06',
      'text': 'ಮಗುವಿನ ಹೆಸರು:',
      'type': 'text',
      'is_required': true,
    },
    {
      'key': 'kn_endline_q07',
      'text': 'ಮಗುವಿನ ಲಿಂಗ:',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಗಂಡು', 'ಹೆಣ್ಣು', 'ಇತರೆ'],
    },
    {
      'key': 'kn_endline_q08',
      'text': 'ನಿನ್ನೆ ಮಗು ಎಷ್ಟು ಬಾರಿ ಘನ ಅಥವಾ ಅರೆ-ಘನ ಆಹಾರವನ್ನು ಸೇವಿಸಿದೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['1 ಬಾರಿ', '2 ಬಾರಿ', '3 ಬಾರಿ ಅಥವಾ ಅದಕ್ಕಿಂತ ಹೆಚ್ಚು', 'ತಿನ್ನಲಿಲ್ಲ'],
    },
    {
      'key': 'kn_endline_q09',
      'text': 'ನಿನ್ನೆ ಮಗು ಈ ಕೆಳಗಿನ ಗುಂಪುಗಳಿಂದ ಆಹಾರವನ್ನು ಸೇವಿಸಿದೆಯೇ? (ಅನ್ವಯವಾಗುವ ಎಲ್ಲವನ್ನೂ ಗುರುತಿಸಿ)',
      'type': 'multi_choice',
      'is_required': true,
      'options': [
        'ಧಾನ್ಯಗಳು/ಬೇರುಗಳು/ಗೆಡ್ಡೆಗಳು',
        'ಬೇಳೆ ಪದಾರ್ಥಗಳು (ಕಾಳುಗಳು, ಬೇಳೆ, ಕಡಲೆ)',
        'ಹಾಲು ಮತ್ತು ಹಾಲು ಉತ್ಪನ್ನಗಳು (ಡೈರಿ)',
        'ಮೊಟ್ಟೆಗಳು',
        'ಮಾಂಸದ ಆಹಾರಗಳು',
        'ಹಣ್ಣುಗಳು ಮತ್ತು ತರಕಾರಿಗಳು',
        'ಎದೆ ಹಾಲು',
      ],
    },
    {
      'key': 'kn_endline_q10',
      'text': 'ಮಗುವಿಗೆ ಅಂಗನವಾಡಿ ಕೇಂದ್ರದಿಂದ ಮನೆಗೆ ತೆಗೆದುಕೊಂಡು ಹೋಗುವ ಪೌಷ್ಟಿಕ ಪಡಿತರ (THR) ದೊರಕುತ್ತದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು, ನಿಯಮಿತವಾಗಿ', 'ಹೌದು, ಅನಿಯಮಿತವಾಗಿ', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_endline_q11',
      'text': 'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಮಗು ಎಷ್ಟು ದಿನಗಳಲ್ಲಿ ಅಂಗನವಾಡಿ ಕೇಂದ್ರಕ್ಕೆ ಹಾಜರಾಗಿತ್ತು?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['0 ದಿನಗಳು', '1–2 ದಿನಗಳು', '3–4 ದಿನಗಳು'],
    },
    {
      'key': 'kn_endline_q12',
      'text': 'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಅಂಗನವಾಡಿ ಕೇಂದ್ರದಲ್ಲಿ ನೀಡಿದ ಬಿಸಿ ಬೇಯಿಸಿದ ಊಟವನ್ನು ಮಗು ಒಟ್ಟು ಎಷ್ಟು ದಿನ ಸೇವಿಸಿದೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['0 ದಿನಗಳು', '1–2 ದಿನಗಳು', '3–4 ದಿನಗಳು', '5–6 ದಿನಗಳು'],
    },
    {
      'key': 'kn_endline_q13',
      'text': 'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಅಂಗನವಾಡಿ ಕೇಂದ್ರದಲ್ಲಿ ಮಗು ಎಷ್ಟು ದಿನಗಳಲ್ಲಿ ಉಪಾಹಾರವನ್ನು ತಿಂದಿತು?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['0 ದಿನಗಳು', '1–2 ದಿನಗಳು', '3–4 ದಿನಗಳು', '5–6 ದಿನಗಳು'],
    },
    {
      'key': 'kn_endline_q14',
      'text': 'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಅಂಗನವಾಡಿ ಕೇಂದ್ರದಲ್ಲಿ ಮಗು ಎಷ್ಟು ದಿನಗಳಲ್ಲಿ ಮೊಟ್ಟೆಯನ್ನು ತಿಂದಿತು?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['0 ದಿನ', '1 ದಿನ', '2 ದಿನ', '2 ದಿನಕ್ಕಿಂತ ಹೆಚ್ಚು'],
    },
    {
      'key': 'kn_endline_q15',
      'text': 'ಕಳೆದ 1 ತಿಂಗಳಲ್ಲಿ, ಅಂಗನವಾಡಿ ಆಹಾರದಲ್ಲಿ ನೀವು ಯಾವುದೇ ಗುಣಮಟ್ಟಕ್ಕೆ ಸಂಬಂಧಿಸಿದ ಸಮಸ್ಯೆಗಳನ್ನು ಎದುರಿಸಿದ್ದೀರಾ? (ಅನ್ವಯವಾಗುವ ಎಲ್ಲವನ್ನೂ ಗುರುತಿಸಿ)',
      'type': 'multi_choice',
      'is_required': true,
      'options': [
        'ಯಾವುದೇ ಸಮಸ್ಯೆಗಳಿಲ್ಲ',
        'ಮಗುವಿಗೆ ಆಹಾರದ ಪ್ರಮಾಣ ಸಾಕಾಗಲಿಲ್ಲ',
        'ಆಹಾರ ತಾಜಾವಾಗಿರಲಿಲ್ಲ / ಗುಣಮಟ್ಟದ ಸಮಸ್ಯೆಗಳಿದ್ದವು',
        'ಮಗುವಿಗೆ ರುಚಿ ಇಷ್ಟವಾಗಲಿಲ್ಲ',
        'ಮೊಟ್ಟೆಗಳು ಕಳಪೆ ಗುಣಮಟ್ಟದ್ದಾಗಿದ್ದವು',
        'ಇತರೆ (ನಿರ್ದಿಷ್ಟಪಡಿಸಿ)',
      ],
    },
    {
      'key': 'kn_endline_q16',
      'text': 'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಮಗುವಿಗೆ ಜಂಕ್ ಅಥವಾ ಪ್ಯಾಕ್ ಮಾಡಿದ ಆಹಾರಕ್ಕಾಗಿ ಎಷ್ಟು ಹಣವನ್ನು ಖರ್ಚು ಮಾಡಲಾಗಿದೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['₹0 (ಖರ್ಚು ಮಾಡಿಲ್ಲ)', '₹1–50', '₹51–100', '₹101–250', '₹250 ಕ್ಕಿಂತ ಹೆಚ್ಚು'],
    },
    {
      'key': 'kn_endline_q17',
      'text': 'ಕಳೆದ ಎರಡು ವಾರಗಳಲ್ಲಿ, ಮಗುವಿಗೆ ಯಾವುದೇ ಕಾಯಿಲೆಗಳಿದ್ದವೆಯೇ? (ಅನ್ವಯವಾಗುವ ಎಲ್ಲವನ್ನೂ ಗುರುತಿಸಿ)',
      'type': 'multi_choice',
      'is_required': true,
      'options': ['ಅತಿಸಾರ', 'ವೇಗವಾಗಿ ಅಥವಾ ಉಸಿರಾಟದ ತೊಂದರೆಯೊಂದಿಗೆ ಕೆಮ್ಮು', 'ಯಾವುದೂ ಇಲ್ಲ'],
    },
    {
      'key': 'kn_endline_q18',
      'text': 'ಮಗು ಅನಾರೋಗ್ಯದಿಂದ ಬಳಲುತ್ತಿರುವಾಗ, ನೀವು ಸಾಮಾನ್ಯವಾಗಿ ಆಹಾರ ಮತ್ತು ಹಾಲುಣಿಸುವಿಕೆಯನ್ನು ಮುಂದುವರಿಸುತ್ತೀರಾ?',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಹೌದು, ಅದೇ ಪ್ರಮಾಣದಲ್ಲಿ ಅಥವಾ ಹೆಚ್ಚು ನೀಡಲಾಗುತ್ತದೆ',
        'ಹೌದು, ಆದರೆ ಸಾಮಾನ್ಯಕ್ಕಿಂತ ಕಡಿಮೆ ನೀಡಲಾಗುತ್ತದೆ',
        'ಇಲ್ಲ, ಆಹಾರ ಅಥವಾ ಹಾಲುಣಿಸುವಿಕೆಯನ್ನು ನಿಲ್ಲಿಸಲಾಗುತ್ತದೆ',
        'ಗೊತ್ತಿಲ್ಲ / ಹೇಳಲು ಸಾಧ್ಯವಿಲ್ಲ',
      ],
    },
    {
      'key': 'kn_endline_q19',
      'text': 'ಮಗುವಿನ ತೂಕ (ಕೆಜಿ) ಎಷ್ಟು?',
      'type': 'decimal',
      'is_required': true,
      'is_anthropometric': true,
    },
    {
      'key': 'kn_endline_q20',
      'text': 'ಮಗುವಿನ ಎತ್ತರ / ಉದ್ದ (ಸೆಂ.ಮೀ.) ಎಷ್ಟು?',
      'type': 'decimal',
      'is_required': true,
      'is_anthropometric': true,
    },
    {
      'key': 'kn_endline_q21',
      'text': 'ಮಗುವಿನ ಮಧ್ಯ-ಮೇಲಿನ ತೋಳಿನ ಸುತ್ತಳತೆ (MUAC) (ಸೆಂ.ಮೀ.) ಎಷ್ಟು?',
      'type': 'decimal',
      'is_required': true,
      'is_anthropometric': true,
    },
    {
      'key': 'kn_endline_q22',
      'text': 'ಬೇಸಲೈನ್‌ನಿಂದ ಹೋಲಿಸಿದರೆ, ತೂಕ ಹೆಚ್ಚಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ', 'ಬೇಸಲೈನ್ ಡೇಟಾ ಲಭ್ಯವಿಲ್ಲ'],
    },
    {
      'key': 'kn_endline_q23',
      'text': 'ಬೇಸಲೈನ್‌ನಿಂದ ಹೋಲಿಸಿದರೆ, ಎತ್ತರ ಹೆಚ್ಚಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ', 'ಬೇಸಲೈನ್ ಡೇಟಾ ಲಭ್ಯವಿಲ್ಲ'],
    },
    {
      'key': 'kn_endline_q24',
      'text': 'ಬೇಸಲೈನ್‌ನಿಂದ ಹೋಲಿಸಿದರೆ, MUAC ಹೆಚ್ಚಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ', 'ಬೇಸಲೈನ್ ಡೇಟಾ ಲಭ್ಯವಿಲ್ಲ'],
    },
  ];

  Future<void> seedEndline() async {
    int displayOrder = 1;

    print("🌱 EndlineSeeder: start (projectDocId=$projectDocId)");

    for (final q in endlineQuestions) {
      final questionId = await _upsertQuestion(q);
      await _upsertOptions(questionId, q);
      await _upsertProjectLink(questionId, q, displayOrder: displayOrder++);
    }

    print("EndlineSeeder: done");
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
    final phase = Constants.phaseEndline;

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
