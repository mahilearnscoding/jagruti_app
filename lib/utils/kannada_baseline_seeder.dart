// Kannada Baseline Survey Seeder (56 questions)
// 
// What this does:
// - Inserts (or reuses) Question docs in `questions`
// - Inserts (or reuses) Option docs in `question_options` (for choice questions)
// - Links each question to a specific Project in `project_questions` for the "baseline" phase
//
// IMPORTANT:
// - `projectDocId` = the *document $id* from your `projects` collection (the same id you pass into Baseline screen),
//   NOT the Appwrite Console Project ID.
//
// Usage (run once per project):
//   final seeder = KannadaBaselineSeeder(
//     aw: AppwriteService.I,
//     projectDocId: '<projects_doc_$id>',
//   );
//   await seeder.seedBaseline();
//
// Notes:
// - Idempotent: safe to run multiple times; it won’t duplicate.
// - Make sure your Appwrite permissions allow CREATE on these collections when you run it.

import 'package:appwrite/appwrite.dart';
import '../services/appwrite_service.dart';
import '../utils/constants.dart';

class KannadaBaselineSeeder {
  final AppwriteService aw;
  final String projectDocId;

  KannadaBaselineSeeder({required this.aw, required this.projectDocId});

  static const List<Map<String, dynamic>> baselineQuestions = [
    // --- SECTION 1: HOUSEHOLD INFO (1–17) ---
    {
      'key': 'kn_q01',
      'text': 'ಮನೆಯ ಮುಖ್ಯಸ್ಥರ ಹೆಸರು:',
      'type': 'text',
      'is_required': true,
    },
    {
      'key': 'kn_q02',
      'text': 'ಮನೆಯ ಮುಖ್ಯಸ್ಥರ ಲಿಂಗ:',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಪುರುಷ', 'ಮಹಿಳೆ', 'ಇತರೆ'],
    },
    {
      'key': 'kn_q03',
      'text': 'ಮನೆಯಲ್ಲಿರುವ ಒಟ್ಟು ಸದಸ್ಯರ ಸಂಖ್ಯೆ:',
      'type': 'single_choice',
      'is_required': true,
      'options': ['1–3', '4–5', '6–7', '8 ಅಥವಾ ಹೆಚ್ಚು'],
    },
    {
      'key': 'kn_q04',
      'text': 'ಮನೆಯ ಸಾಮಾಜಿಕ ಗುಂಪು / ಜಾತಿ:',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಪರಿಶಿಷ್ಟ ಜಾತಿ (SC)',
        'ಪರಿಶಿಷ್ಟ ಪಂಗಡ (ST)',
        'ಇತರ ಹಿಂದುಳಿದ ವರ್ಗ (OBC)',
        'ಸಾಮಾನ್ಯ ವರ್ಗ',
        'ಹೇಳಲು ಇಷ್ಟಪಡುವುದಿಲ್ಲ',
      ],
    },
    {
      'key': 'kn_q05',
      'text': 'ಮನೆಯ ಪ್ರಾಥಮಿಕ ಉದ್ಯೋಗ (ಆದಾಯದ ಮುಖ್ಯ ಮೂಲ):',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಗಣಿಗಾರಿಕೆಗೆ ಸಂಬಂಧಿಸಿದ ಕೆಲಸ (ಗಣಿ/ಸಾರಿಗೆ/ಲೋಡಿಂಗ್/ಕ್ರಷರ್)',
        'ದಿನಗೂಲಿ ಕೆಲಸ (ಗಣಿಗಾರಿಕೆಯೇತರ)',
        'ಕೃಷಿ (ಸ್ವಂತ ಭೂಮಿ)',
        'ಸಂಬಳದ ಕೆಲಸ',
        'ಸ್ವಯಂ ಉದ್ಯೋಗಿ / ವ್ಯವಹಾರ',
        'ಇತರೆ (ನಿರ್ದಿಷ್ಟಪಡಿಸಿ)',
      ],
    },
    {
      'key': 'kn_q06',
      'text': 'ಮನೆಯಲ್ಲಿ ಯಾರಾದರೂ ಪೋಷಕರು ಕೆಲಸಕ್ಕಾಗಿ ವಲಸೆ ಹೋಗುತ್ತಾರೆಯೇ (ದೀರ್ಘಕಾಲದವರೆಗೆ ದೂರ ಇರುತ್ತಾರೆಯೇ)?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಇಲ್ಲ', 'ಹೌದು, ತಂದೆ', 'ಹೌದು, ತಾಯಿ'],
    },
    {
      'key': 'kn_q07',
      'text': 'ಮನೆಯಲ್ಲಿ MGNREGA ಉದ್ಯೋಗ ಕಾರ್ಡ್ ಇದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ', 'ಗೊತ್ತಿಲ್ಲ'],
    },
    {
      'key': 'kn_q08',
      'text': 'ಗಣಿಗಾರಿಕೆ/ಸಾರಿಗೆಯಿಂದಾಗಿ ನಿಮ್ಮ ಮನೆ/ಸಮುದಾಯದಲ್ಲಿ ಬಹಳಷ್ಟು ಧೂಳು ತುಂಬಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು, ಬಹಳಷ್ಟು', 'ಕೆಲವು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_q09',
      'text': 'ತಾಯಿಯ ಸಾಕ್ಷರತಾ ಸ್ಥಿತಿ:',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಓದಲು ಅಥವಾ ಬರೆಯಲು ಬರುವುದಿಲ್ಲ',
        'ಓದಲು ಮತ್ತು ಬರೆಯಲು ಬರುತ್ತದೆ',
        'ಪ್ರಾಥಮಿಕ ಶಾಲೆ ಅಥವಾ ಅದಕ್ಕಿಂತ ಹೆಚ್ಚಿನದನ್ನು ಪೂರ್ಣಗೊಳಿಸಲಾಗಿದೆ',
      ],
    },
    {
      'key': 'kn_q10',
      'text': 'ತಂದೆಯ ಸಾಕ್ಷರತಾ ಸ್ಥಿತಿ:',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಓದಲು ಅಥವಾ ಬರೆಯಲು ಬರುವುದಿಲ್ಲ',
        'ಓದಲು ಮತ್ತು ಬರೆಯಲು ಬರುತ್ತದೆ',
        'ಪ್ರಾಥಮಿಕ ಶಾಲೆ ಅಥವಾ ಅದಕ್ಕಿಂತ ಹೆಚ್ಚಿನ ಶಿಕ್ಷಣವನ್ನು ಪೂರ್ಣಗೊಳಿಸಲಾಗಿದೆ',
      ],
    },
    {
      'key': 'kn_q11',
      'text': 'ಮನೆಯು ಮುಖ್ಯವಾಗಿ ಯಾವ ರೀತಿಯ ಅಡುಗೆ ಇಂಧನವನ್ನು ಬಳಸುತ್ತದೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'LPG / PNG',
        'ವಿದ್ಯುತ್',
        'ಉರುವಲು',
        'ಹಸುವಿನ ಸಗಣಿ / ಬೆಳೆ ಉಳಿಕೆ',
        'ಇತರೆ (ನಿರ್ದಿಷ್ಟಪಡಿಸಿ)',
      ],
    },
    {
      'key': 'kn_q12',
      'text': 'ಮನೆಯು ನೈರ್ಮಲ್ಯ ಸೌಲಭ್ಯವನ್ನು (ಶೌಚಾಲಯ) ಹೊಂದಿದೆಯೇ ಮತ್ತು ಶೌಚಾಲಯದ ಒಳಗೆ ನೀರು ಲಭ್ಯವಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಮನೆಯೊಳಗೆ ನೀರಿನ ಸಂಪರ್ಕ ಹೊಂದಿರುವ ಶೌಚಾಲಯ',
        'ಮನೆಯೊಳಗೆ ನೀರಿನ ಸಂಪರ್ಕವಿಲ್ಲದ ಶೌಚಾಲಯ',
        'ನೀರು ಸಂಪರ್ಕವಿರುವ ಹಂಚಿಕೆಯ ಶೌಚಾಲಯ',
        'ನೀರು ಸಂಪರ್ಕವಿಲ್ಲದ ಹಂಚಿಕೆಯ ಶೌಚಾಲಯ',
        'ಶೌಚಾಲಯ ಇಲ್ಲ / ಬಯಲಿನಲ್ಲಿ ಮಲವಿಸರ್ಜನೆ',
      ],
    },
    {
      'key': 'kn_q13',
      'text': 'ಮನೆಯು ಕುಡಿಯುವ ನೀರಿನ ಮುಖ್ಯ ಮೂಲ:',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಮನೆ/ಆಂಗಣದಲ್ಲಿ ಪೈಪ್ ನೀರು',
        'ಸಾರ್ವಜನಿಕ ನಲ್ಲಿ / ಸ್ಟ್ಯಾಂಡ್‌ಪೈಪ್',
        'ಕೈಪಂಪ್ / ಬೋರ್‌ವೆಲ್',
        'ಸಂರಕ್ಷಿತ ಬಾವಿ',
        'ಮೇಲ್ಮೈ ನೀರು (ನದಿ, ಕೊಳ, ಇತ್ಯಾದಿ)',
        'ಇತರೆ (ನಿರ್ದಿಷ್ಟಪಡಿಸಿ)',
      ],
    },
    {
      'key': 'kn_q14',
      'text': 'ಮನೆಯಲ್ಲಿ ಸಾಬೂನು ಮತ್ತು ನೀರಿನೊಂದಿಗೆ ಕೈ ತೊಳೆಯುವ ಸೌಲಭ್ಯ ಲಭ್ಯವಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_q15',
      'text': 'ಮನೆಯ ಸಾಮಾನ್ಯ ಆಹಾರ ಪದ್ಧತಿ ಏನು?',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಸಸ್ಯಾಹಾರಿ',
        'ಮಾಂಸಾಹಾರಿ',
        'ಮೊಟ್ಟೆ ಮಾತ್ರ ಸೇವಿಸುವವರು (Eggetarian)',
        'ಮಿಶ್ರ (ದಿನಕ್ಕೆ ಅನುಗುಣವಾಗಿ ಬದಲಾಗುತ್ತದೆ)',
      ],
    },
    {
      'key': 'kn_q16',
      'text': 'ಮನೆಯವರಿಗೆ ಬಿ.ಪಿ.ಎಲ್ / ಪಡಿತರ ಚೀಟಿ (ರೇಷನ್ ಕಾರ್ಡ್) ಇದೆಯೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ', 'ಗೊತ್ತಿಲ್ಲ'],
    },
    {
      'key': 'kn_q17',
      'text': 'ನಿಯಮಾನುಸಾರ ಸಾರ್ವಜನಿಕ ವಿತರಣಾ ವ್ಯವಸ್ಥೆಯಿಂದ (PDS) ಮನೆಯವರಿಗೆ ಆಹಾರ ಧಾನ್ಯಗಳು ಸಾಮಾನ್ಯವಾಗಿ ಲಭ್ಯವಾಗುತ್ತವೆಯೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು, ನಿಯಮಿತವಾಗಿ', 'ಹೌದು, ಆದರೆ ಅಸಮರ್ಪಕ / ಭಾಗಶಃ', 'ಇಲ್ಲ', 'ಗೊತ್ತಿಲ್ಲ'],
    },

    // --- SECTION 2: MOTHER DETAILS (18–25) ---
    {
      'key': 'kn_q18',
      'text': 'ತಾಯಿಯ ಹೆಸರು:',
      'type': 'text',
      'is_required': true,
    },
    {
      'key': 'kn_q19',
      'text': 'ತಾಯಿಯ ವಯಸ್ಸು (ಪೂರ್ಣಗೊಂಡ ವರ್ಷಗಳಲ್ಲಿ):',
      'type': 'number',
      'is_required': true,
    },
    {
      'key': 'kn_q20',
      'text': 'a. ಗ್ರಾಮ / ಪಟ್ಟಣದ ಹೆಸರು:',
      'type': 'text',
      'is_required': true,
    },
    {
      'key': 'kn_q21',
      'text': 'b. ಪ್ರದೇಶದ ಪ್ರಕಾರ:',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಗ್ರಾಮೀಣ', 'ನಗರ'],
    },
    {
      'key': 'kn_q22',
      'text': 'ತಾಯಿಯ ಶೈಕ್ಷಣಿಕ ಸಾಧನೆ:',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಔಪಚಾರಿಕ ಶಾಲಾ ಶಿಕ್ಷಣವಿಲ್ಲ',
        'ಪ್ರಾಥಮಿಕ ಶಾಲೆ (5ನೇ ತರಗತಿಯವರೆಗೆ)',
        'ಹಿರಿಯ ಪ್ರಾಥಮಿಕ (6–8ನೇ ತರಗತಿ)',
        'ಮಾಧ್ಯಮಿಕ (9–10ನೇ ತರಗತಿ)',
        'ಪ್ರೌಢಶಾಲೆ (11–12ನೇ ತರಗತಿ)',
        'ಪದವಿ ಅಥವಾ ಅದಕ್ಕಿಂತ ಹೆಚ್ಚಿನವರು',
      ],
    },
    {
      'key': 'kn_q23',
      'text': 'ತಾಯಿಯ ರಕ್ತಹೀನತೆ ಸ್ಥಿತಿ (ಆರೋಗ್ಯ ಕಾರ್ಡ್‌ನಿಂದ / ವರದಿ ಮಾಡಿದಂತೆ):',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ರಕ್ತಹೀನತೆ ಇಲ್ಲ',
        'ಸೌಮ್ಯ ರಕ್ತಹೀನತೆ',
        'ಮಧ್ಯಮ ರಕ್ತಹೀನತೆ',
        'ತೀವ್ರ ರಕ್ತಹೀನತೆ',
        'ಪರೀಕ್ಷಿಸಲಾಗಿಲ್ಲ / ತಿಳಿದಿಲ್ಲ',
      ],
    },
    {
      'key': 'kn_q24',
      'text': 'ತಾಯಿಯ ಉದ್ಯೋಗ (ಮುಖ್ಯ ಚಟುವಟಿಕೆ):',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಗೃಹಿಣಿ',
        'ಕೃಷಿ ಕಾರ್ಮಿಕ',
        'ಕೃಷಿಯೇತರ ಕಾರ್ಮಿಕ',
        'ಸಂಬಳದ ಉದ್ಯೋಗ',
        'ಸ್ವಯಂ ಉದ್ಯೋಗಿ',
        'ಇತರೆ (ನಿರ್ದಿಷ್ಟಪಡಿಸಿ)',
      ],
    },
    {
      'key': 'kn_q25',
      'text': 'ಈ ಮನೆಯಲ್ಲಿ ಆರೋಗ್ಯ ರಕ್ಷಣೆ, ಪ್ರಮುಖ ಮನೆ ಖರೀದಿಗಳು ಹಾಗೂ ಮಕ್ಕಳ ಶಿಕ್ಷಣದಂತಹ ಪ್ರಮುಖ ವಿಷಯಗಳ ಕುರಿತು ಸಾಮಾನ್ಯವಾಗಿ ಯಾರು ನಿರ್ಧಾರಗಳನ್ನು ತೆಗೆದುಕೊಳ್ಳುತ್ತಾರೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ತಾಯಿ ಮಾತ್ರ',
        'ತಾಯಿ ಮತ್ತು ಸಂಗಾತಿ / ಇತರ ಕುಟುಂಬ ಸದಸ್ಯರು ಜಂಟಿಯಾಗಿ',
        'ಸಂಗಾತಿ ಮಾತ್ರ',
        'ಇತರ ಕುಟುಂಬ ಸದಸ್ಯರು',
        'ತಾಯಿ ಮನೆಯ ನಿರ್ಧಾರಗಳಲ್ಲಿ ಭಾಗವಹಿಸುವುದಿಲ್ಲ',
      ],
    },

    // --- SECTION 3: CHILD DETAILS (26–32) ---
    {
      'key': 'kn_q26',
      'text': 'ಮಗುವಿನ ಹೆಸರು (ಅಥವಾ ಐಡಿ):',
      'type': 'text',
      'is_required': true,
    },
    {
      'key': 'kn_q27',
      'text': 'ಮಗುವಿನ ಜನ್ಮ ದಿನಾಂಕ:',
      'type': 'date',
      'is_required': true,
    },
    {
      'key': 'kn_q28',
      'text': 'ಮಗುವಿನ ಲಿಂಗ:',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಗಂಡು', 'ಹೆಣ್ಣು', 'ಇತರೆ'],
    },
    {
      'key': 'kn_q29',
      'text': 'ಮಗುವಿನ ಜನನ ಕ್ರಮ:',
      'type': 'single_choice',
      'is_required': true,
      'options': ['1ನೇ', '2ನೇ', '3ನೇ ಅಥವಾ ಅದಕ್ಕಿಂತ ಹೆಚ್ಚಿನ'],
    },
    {
      'key': 'kn_q30',
      'text': 'ತಾಯಿ ಹಗಲಿನ ಸಮಯದಲ್ಲಿ ಲಭ್ಯವಿರದಿದ್ದರೆ, ಮಗುವಿನ ಪ್ರಾಥಮಿಕ ಆರೈಕೆದಾರರು ಯಾರು?',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ತಂದೆ',
        'ಅಜ್ಜಿ / ಅಜ್ಜ',
        'ಇತರ ವಯಸ್ಕ ಕುಟುಂಬ ಸದಸ್ಯರು',
        'ಹಿರಿಯ ಸಹೋದರ',
        'ನೆರೆಹೊರೆಯವರು / ಶಿಶುಪಾಲನಾ ಪೂರೈಕೆದಾರರು',
        'ಅಂಗನವಾಡಿ ಕಾರ್ಯಕರ್ತೆ / ಕೇಂದ್ರ',
        'ಇತರೆ (ನಿರ್ದಿಷ್ಟಪಡಿಸಿ)',
      ],
    },
    {
      'key': 'kn_q31',
      'text': 'ಒಂದು ಸಾಮಾನ್ಯ ದಿನದಲ್ಲಿ, ಆರೈಕೆದಾರರು ಮಗುವಿನೊಂದಿಗೆ ಸಂವಹನ ನಡೆಸಲು (ಮಾತನಾಡುವುದು, ಆಟವಾಡುವುದು, ಹಾಡುವುದು, ಗಮನವಿಟ್ಟು ಆಹಾರ ನೀಡುವುದು) ಎಷ್ಟು ಸಮಯವನ್ನು ಕಳೆಯುತ್ತಾರೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        '15 ನಿಮಿಷಗಳಿಗಿಂತ ಕಡಿಮೆ ಸಮಯ',
        '15–30 ನಿಮಿಷಗಳು',
        '30 ನಿಮಿಷಗಳಿಗಿಂತ ಹೆಚ್ಚು ಸಮಯ',
      ],
    },
    {
      'key': 'kn_q32',
      'text': 'ಮಗು ಪ್ರಸ್ತುತ ಅಂಗನವಾಡಿ ಕೇಂದ್ರಕ್ಕೆ ದಾಖಲಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ', 'ಗೊತ್ತಿಲ್ಲ'],
    },

    // --- SECTION 4A: DIET (33–40) ---
    {
      'key': 'kn_q33',
      'text': 'ನೀವು ಮಗುವಿಗೆ ಎದೆ ಹಾಲು ಹೊರತುಪಡಿಸಿ ಇತರ ಆಹಾರವನ್ನು ಯಾವ ವಯಸ್ಸಿನಲ್ಲಿ ನೀಡಲು ಪ್ರಾರಂಭಿಸಿದ್ದೀರಿ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['6 ತಿಂಗಳ ಮೊದಲು', '6–8 ತಿಂಗಳ ನಡುವೆ', '9–11 ತಿಂಗಳ ನಡುವೆ', '11 ತಿಂಗಳ ನಂತರ', 'ನೆನಪಿಲ್ಲ'],
    },
    {
      'key': 'kn_q34',
      'text': 'ಮಗು ಈಗ ಸಾಮಾನ್ಯವಾಗಿ ಯಾವ ರೀತಿಯ ಆಹಾರವನ್ನು ಸೇವಿಸುತ್ತದೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ತೆಳುವಾದ ದ್ರವ ಆಹಾರಗಳು ಮಾತ್ರ (ಅಕ್ಕಿ ನೀರು, ಬೇಳೆ ನೀರು, ಹಾಲು)',
        'ಅರೆ-ಘನ ಆಹಾರಗಳು (ಹಿಸುಕಿದ ಅನ್ನ, ಖಿಚಡಿ, ಗಂಜಿ)',
        'ವಯಸ್ಸಿಗೆ ಸೂಕ್ತವಾದ ದಪ್ಪ / ಘನ ಆಹಾರಗಳು',
      ],
    },
    {
      'key': 'kn_q35',
      'text': 'ನಿನ್ನೆ ಮಗು ಎಷ್ಟು ಬಾರಿ ಘನ ಅಥವಾ ಅರೆ-ಘನ ಆಹಾರವನ್ನು ಸೇವಿಸಿದೆ (ಎದೆ ಹಾಲು ಹೊರತುಪಡಿಸಿ)?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['1 ಬಾರಿ', '2 ಬಾರಿ', '3 ಬಾರಿ ಅಥವಾ ಅದಕ್ಕಿಂತ ಹೆಚ್ಚು', 'ತಿನ್ನಲಿಲ್ಲ'],
    },
    {
      'key': 'kn_q36',
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
      'key': 'kn_q37',
      'text': 'ಮಗುವಿಗೆ ಅಂಗನವಾಡಿ ಕೇಂದ್ರದಿಂದ ಮನೆಗೆ ತೆಗೆದುಕೊಂಡು ಹೋಗುವ ಪೌಷ್ಟಿಕ ಪಡಿತರ (THR) ದೊರಕುತ್ತದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು, ನಿಯಮಿತವಾಗಿ', 'ಹೌದು, ಅನಿಯಮಿತವಾಗಿ', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_q38',
      'text': 'ಹೌದು ಎಂದಾದರೆ, ಪೌಷ್ಟಿಕ ಪಡಿತರ (THR) ಅನ್ನು ಸಾಮಾನ್ಯವಾಗಿ ಹೇಗೆ ಬಳಸಲಾಗುತ್ತದೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಮುಖ್ಯವಾಗಿ ಮಗುವಿಗೆ ನೀಡಲಾಗುತ್ತದೆ',
        'ಕುಟುಂಬದ ಸದಸ್ಯರೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳಲಾಗುತ್ತದೆ',
        'ಕೆಲವೊಮ್ಮೆ ಮಾತ್ರ ಮಗುವಿಗೆ ಬಳಸಲಾಗುತ್ತದೆ',
        'ಇತರೆ (ದಯವಿಟ್ಟು ವಿವರಿಸಿ)',
      ],
    },
    {
      'key': 'kn_q39',
      'text': 'ಪೌಷ್ಟಿಕ ಪಡಿತರ (THR) ಅನ್ನು ಸಾಮಾನ್ಯವಾಗಿ ಮನೆಯಲ್ಲಿ ಹೇಗೆ ತಯಾರಿಸಿ ಮಗುವಿಗೆ ನೀಡಲಾಗುತ್ತದೆ? (ಸಾಮಾನ್ಯವಾಗಿ ಅನುಸರಿಸುವ ವಿಧಾನಕ್ಕೆ ಹೊಂದುವ ಆಯ್ಕೆಯನ್ನು ಗುರುತಿಸಿ)',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ನೀರಿನಲ್ಲಿ ಮಾತ್ರ ಕುದಿಸಿ ತೆಳುವಾದ ಗಂಜಿಯಾಗಿ ನೀಡಲಾಗುತ್ತದೆ',
        'ದಪ್ಪ ಗಂಜಿಯಾಗಿ ತಯಾರಿಸಲಾಗುತ್ತದೆ / ಸರಿಯಾಗಿ ಬೇಯಿಸಲಾಗುತ್ತದೆ',
        'ಲಡ್ಡು, ಬರ್ಫಿ, ದೋಸೆ ಅಥವಾ ಇತರ ಆಹಾರ ಪದಾರ್ಥಗಳಾಗಿ ತಯಾರಿಸಲಾಗುತ್ತದೆ',
        'ಹಾಲು ಅಥವಾ ಇತರ ಆಹಾರಗಳೊಂದಿಗೆ ಬೆರೆಸಿ ನೀಡಲಾಗುತ್ತದೆ',
        'ಹೇಗೆ ತಯಾರಿಸಬೇಕು ಎಂಬುದು ತಿಳಿದಿಲ್ಲ / ವಿರಳವಾಗಿ ಬಳಸಲಾಗುತ್ತದೆ',
      ],
    },
    {
      'key': 'kn_q40',
      'text': 'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಮಗುವಿಗೆ ಜಂಕ್ ಅಥವಾ ಪ್ಯಾಕ್ ಮಾಡಿದ ಆಹಾರಕ್ಕಾಗಿ ಸುಮಾರು ಎಷ್ಟು ಹಣವನ್ನು ಖರ್ಚು ಮಾಡಲಾಗಿದೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['₹0 (ಖರ್ಚು ಮಾಡಿಲ್ಲ)', '₹1–50', '₹51–100', '₹101–250', '₹250 ಕ್ಕಿಂತ ಹೆಚ್ಚು'],
    },

    // --- SECTION 4B: DIET (41–51) ---
    {
      'key': 'kn_q41',
      'text': 'ನಿನ್ನೆ, ಮಗು ಅಂಗನವಾಡಿ ಕೇಂದ್ರದಿಂದ ಪಡೆದ ಆಹಾರ ಹಾಗೂ ಮನೆಯಲ್ಲಿ ತಯಾರಿಸಿದ ಆಹಾರವನ್ನು ಸೇರಿಸಿ (ಊಟ ಅಥವಾ ತಿಂಡಿಗಳು), ಒಟ್ಟು ಎಷ್ಟು ಬಾರಿ ಸೇವಿಸಿದೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['0–2 ಬಾರಿ', '3 ಬಾರಿ', '4 ಅಥವಾ ಅದಕ್ಕಿಂತ ಹೆಚ್ಚು ಬಾರಿ'],
    },
    {
      'key': 'kn_q42',
      'text': 'ನಿನ್ನೆ, ಮಗು ಈ ಕೆಳಗಿನ ಗುಂಪುಗಳಿಂದ ಆಹಾರವನ್ನು ತಿಂದಿದೆಯೇ? (ಅನ್ವಯವಾಗುವ ಎಲ್ಲವನ್ನೂ ಗುರುತಿಸಿ)',
      'type': 'multi_choice',
      'is_required': true,
      'options': [
        'ಧಾನ್ಯಗಳು/ಬೇರುಗಳು/ಗೆಡ್ಡೆಗಳು',
        'ದ್ವಿದಳ ಧಾನ್ಯಗಳು (ಬೇಳೆ, ಕಡಲೆ, ಇತ್ಯಾದಿ)',
        'ಹಾಲು ಮತ್ತು ಹಾಲು ಉತ್ಪನ್ನಗಳು (ಡೈರಿ)',
        'ಮೊಟ್ಟೆಗಳು',
        'ಮಾಂಸದ ಆಹಾರಗಳು',
        'ಹಣ್ಣುಗಳು ಮತ್ತು ತರಕಾರಿಗಳು',
        'ಎದೆ ಹಾಲು',
      ],
    },
    {
      'key': 'kn_q43',
      'text': 'ಮಗು ಅಂಗನವಾಡಿ ಕೇಂದ್ರದಲ್ಲಿ ದಾಖಲೆಯಾಗಿದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಹೌದು', 'ಇಲ್ಲ'],
    },
    {
      'key': 'kn_q44',
      'text': 'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಮಗು ಎಷ್ಟು ದಿನಗಳಲ್ಲಿ ಅಂಗನವಾಡಿ ಕೇಂದ್ರಕ್ಕೆ ಹಾಜರಾಗಿತ್ತು?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['0 ದಿನಗಳು', '1–2 ದಿನಗಳು', '3–4 ದಿನಗಳು'],
    },
    {
      'key': 'kn_q45',
      'text': 'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಅಂಗನವಾಡಿ ಕೇಂದ್ರದಲ್ಲಿ ನೀಡಿದ ಬಿಸಿ ಬೇಯಿಸಿದ ಊಟವನ್ನು ಮಗು ಒಟ್ಟು ಎಷ್ಟು ದಿನ ಸೇವಿಸಿದೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['0 ದಿನಗಳು', '1–2 ದಿನಗಳು', '3–4 ದಿನಗಳು', '5–6 ದಿನಗಳು'],
    },
    {
      'key': 'kn_q46',
      'text': 'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಅಂಗನವಾಡಿ ಕೇಂದ್ರದಲ್ಲಿ ಮಗು ಎಷ್ಟು ದಿನಗಳಲ್ಲಿ ಉಪಾಹಾರವನ್ನು ತಿಂದಿತು?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['0 ದಿನಗಳು', '1–2 ದಿನಗಳು', '3–4 ದಿನಗಳು', '5–6 ದಿನಗಳು'],
    },
    {
      'key': 'kn_q47',
      'text': 'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಅಂಗನವಾಡಿ ಕೇಂದ್ರದಲ್ಲಿ ಮಗು ಎಷ್ಟು ದಿನಗಳಲ್ಲಿ ಮೊಟ್ಟೆಯನ್ನು ತಿಂದಿತು?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['0 ದಿನ', '1 ದಿನ', '2 ದಿನ', '2 ದಿನಕ್ಕಿಂತ ಹೆಚ್ಚು'],
    },
    {
      'key': 'kn_q48',
      'text': 'ಕಳೆದ 1 ತಿಂಗಳಲ್ಲಿ, ಅಂಗನವಾಡಿ ಆಹಾರದಲ್ಲಿ (ಉಪಹಾರ, ಮಧ್ಯಾಹ್ನದ ಊಟ ಅಥವಾ ಮೊಟ್ಟೆಗಳು) ನೀವು ಯಾವುದೇ ಗುಣಮಟ್ಟಕ್ಕೆ ಸಂಬಂಧಿಸಿದ ಸಮಸ್ಯೆಗಳನ್ನು ಎದುರಿಸಿದ್ದೀರಾ? (ಅನ್ವಯವಾಗುವ ಎಲ್ಲವನ್ನೂ ಗುರುತಿಸಿ)',
      'type': 'multi_choice',
      'is_required': true,
      'options': [
        'ಯಾವುದೇ ಸಮಸ್ಯೆಗಳಿಲ್ಲ',
        'ಮಗುವಿಗೆ ಆಹಾರದ ಪ್ರಮಾಣ ಸಾಕಾಗಲಿಲ್ಲ',
        'ಆಹಾರ ತಾಜಾವಾಗಿರಲಿಲ್ಲ / ಗುಣಮಟ್ಟದ ಸಮಸ್ಯೆಗಳಿದ್ದವು',
        'ಮಗುವಿಗೆ ರುಚಿ ಇಷ್ಟವಾಗಲಿಲ್ಲ ಮತ್ತು ತಿನ್ನಲು ನಿರಾಕರಿಸಿತು',
        'ಮೊಟ್ಟೆಗಳು ಕಳಪೆ ಗುಣಮಟ್ಟದ್ದಾಗಿದ್ದವು',
        'ಇತರೆ (ನಿರ್ದಿಷ್ಟಪಡಿಸಿ)',
      ],
    },
    {
      'key': 'kn_q49',
      'text': 'ಮಗು ಅಂಗನವಾಡಿಗೆ ಹೋಗುವ ದಿನಗಳಲ್ಲಿ, ಅಲ್ಲಿ ನೀಡಲಾಗುವ ಆಹಾರವನ್ನು ಮಗು ಸಾಮಾನ್ಯವಾಗಿ ತಿನ್ನುತ್ತದೆಯೇ?',
      'type': 'single_choice',
      'is_required': true,
      'options': [
        'ಹೌದು, ಅದರಲ್ಲಿ ಹೆಚ್ಚಿನದನ್ನು ತಿನ್ನುತ್ತದೆ',
        'ಸ್ವಲ್ಪ ತಿನ್ನುತ್ತದೆ, ಆದರೆ ಸಂಪೂರ್ಣವಾಗಿ ತಿನ್ನುವುದಿಲ್ಲ',
        'ಅದು ಸಾಮಾನ್ಯವಾಗಿ ತಿನ್ನುವುದಿಲ್ಲ',
      ],
    },
    {
      'key': 'kn_q50',
      'text': 'ಮಗು ಅಂಗನವಾಡಿಯಲ್ಲಿ ಆಹಾರವನ್ನು ಸೇವಿಸಿದ ದಿನಗಳಲ್ಲಿ, ಮನೆಯಲ್ಲಿ ನೀಡುವ ಆಹಾರದ ಪ್ರಮಾಣಕ್ಕೆ ಸಾಮಾನ್ಯವಾಗಿ ಯಾವ ರೀತಿಯ ಬದಲಾವಣೆ ಆಗುತ್ತದೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['ಮನೆ ಊಟಗಳ ಪ್ರಮಾಣ ಕಡಿಮೆಯಾಗುತ್ತದೆ', 'ಮನೆ ಊಟಗಳಲ್ಲಿ ಯಾವುದೇ ಬದಲಾವಣೆ ಇಲ್ಲ', 'ಮನೆ ಊಟಗಳ ಪ್ರಮಾಣ ಹೆಚ್ಚಾಗುತ್ತದೆ'],
    },
    {
      'key': 'kn_q51',
      'text': 'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಮಗುವಿಗೆ ಜಂಕ್ ಅಥವಾ ಪ್ಯಾಕ್ ಮಾಡಿದ ಆಹಾರಗಳಿಗೆ (ಉದಾಹರಣೆಗೆ: ಬಿಸ್ಕತ್ತುಗಳು, ಚಿಪ್ಸ್, ಸಿಹಿತಿಂಡಿಗಳು, ತ್ವರಿತ ನೂಡಲ್ಸ್, ಸಕ್ಕರೆ ಪಾನೀಯಗಳು) ಒಟ್ಟು ಸುಮಾರು ಎಷ್ಟು ಹಣವನ್ನು ಖರ್ಚು ಮಾಡಲಾಗಿದೆ?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['₹0', '₹1–50', '₹51–100', '₹101–250', '₹250 ಕ್ಕಿಂತ ಹೆಚ್ಚು'],
    },

    // --- SECTION 5: HEALTH & ANTHROPOMETRY (52–56) ---
    {
      'key': 'kn_q52',
      'text': 'ಕಳೆದ ಎರಡು ವಾರಗಳಲ್ಲಿ, ಮಗುವಿಗೆ ಕೆಳಗಿನ ಯಾವುದೇ ಕಾಯಿಲೆಗಳಿದ್ದವೆಯೇ? (ಅನ್ವಯವಾಗುವ ಎಲ್ಲವನ್ನೂ ಗುರುತಿಸಿ)',
      'type': 'multi_choice',
      'is_required': true,
      'options': ['ಅತಿಸಾರ', 'ವೇಗವಾಗಿ ಅಥವಾ ಉಸಿರಾಟದ ತೊಂದರೆಯೊಂದಿಗೆ ಕೆಮ್ಮು', 'ಯಾವುದೂ ಇಲ್ಲ'],
    },
    {
      'key': 'kn_q53',
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
      'key': 'kn_q54',
      'text': 'ಮಗುವಿನ ತೂಕ (ಕೆಜಿ) ಎಷ್ಟು?',
      'type': 'decimal',
      'is_required': true,
      'is_anthropometric': true,
    },
    {
      'key': 'kn_q55',
      'text': 'ಮಗುವಿನ ಎತ್ತರ / ಉದ್ದ (ಸೆಂ.ಮೀ.) ಎಷ್ಟು?',
      'type': 'decimal',
      'is_required': true,
      'is_anthropometric': true,
    },
    {
      'key': 'kn_q56',
      'text': 'ಮಗುವಿನ ಮಧ್ಯ-ಮೇಲಿನ ತೋಳಿನ ಸುತ್ತಳತೆ (MUAC) (ಸೆಂ.ಮೀ.) ಎಷ್ಟು?',
      'type': 'decimal',
      'is_required': true,
      'is_anthropometric': true,
    },
  ];

  Future<void> seedBaseline() async {
    int displayOrder = 1;

    for (final q in baselineQuestions) {
      final questionId = await _upsertQuestion(q);
      await _upsertOptions(questionId, q);
      await _upsertProjectLink(questionId, q, displayOrder: displayOrder++);
    }
  }

  Future<String> _upsertQuestion(Map<String, dynamic> q) async {
    final key = q['key'] as String;

    final existing = await aw.list(
      collectionId: Constants.colQuestions,
      queries: [Query.equal('question_key', key)],
    );

    if (existing.documents.isNotEmpty) {
      return existing.documents.first.$id;
    }

    final created = await aw.create(
      collectionId: Constants.colQuestions,
      data: {
        'question_key': key,
        'question_text': q['text'],
        'answer_type': q['type'], // <-- IMPORTANT: matches QuestionService reading `answer_type`
        'is_active': true,
        'is_anthropometric': q['is_anthropometric'] ?? false,
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
      final value = '${qKey}_opt_${i + 1}'; // stable machine value (avoid unicode issues)

      final existing = await aw.list(
        collectionId: Constants.colQuestionOptions,
        queries: [
          Query.equal('question', questionId),
          Query.equal('option_value', value),
        ],
      );

      if (existing.documents.isNotEmpty) continue;

      await aw.create(
        permissions: [
        Permission.read(Role.any()),
          Permission.write(Role.any()),
        ],
        collectionId: Constants.colQuestionOptions,
        data: {
          'question': questionId,
          'option_value': value,
          'option_label': label,
          'display_order': i + 1,
          'is_active': true,
        },
      );
    }
  }

  Future<void> _upsertProjectLink(
    String questionId,
    Map<String, dynamic> q, {
    required int displayOrder,
  }) async {
    final phase = Constants.phaseBaseline;

    final existing = await aw.list(
      collectionId: Constants.colProjectQuestions,
      queries: [
        Query.equal('project', projectDocId),
        Query.equal('question', questionId),
        Query.equal('phase', phase),
      ],
    );

    if (existing.documents.isNotEmpty) return;

    await aw.create(
      collectionId: Constants.colProjectQuestions,
      data: {
        'project': projectDocId,
        'question': questionId,
        'phase': phase,
        'display_order': displayOrder,
        'is_required': q['is_required'] ?? true,
        'is_active': true,
      },
    );
  }
}
