import 'package:appwrite/appwrite.dart';
import '../services/appwrite_service.dart';
import '../utils/constants.dart';

class BaselineSeeder {
  static Future<void> seedData(String projectDocId) async {
    print('📝 BaselineSeeder.seedData - DISABLED (using existing Kannada questions)');
    return; // Skip seeding - existing Kannada questions in database
    
    final aw = AppwriteService.I;
    await aw.ensureSession();

    
    // excluding duplicate information already collected in child registration
    final baselineQuestions = [
      // section: child Diet, feeding practices & ICDS Services (6-35 months)
      {
        'question': 'At what age did you first start giving the child foods other than breast milk?',
        'type': 'single_select',
        'options': ['Before 6 months', 'Between 6–8 months', 'Between 9–11 months', 'After 11 months', 'Don\'t remember'],
        'category': 'Diet 6-35 months',
        'is_required': true,
        'age_group': '6-35',
        'display_order': 1,
      },
      {
        'question': 'What type of food does the child usually eat now?',
        'type': 'single_select',
        'options': ['Thin liquids only (rice water, dal water, milk)', 'Semi-solid foods (mashed rice, khichdi, porridge)', 'Thick/solid foods appropriate for age'],
        'category': 'Diet 6-35 months',
        'is_required': true,
        'age_group': '6-35',
        'display_order': 2,
      },
      {
        'question': 'Yesterday, how many times did the child eat solid or semi-solid foods (excluding breast milk)?',
        'type': 'single_select',
        'options': ['1 time', '2 times', '3 times or more', 'Did not eat'],
        'category': 'Diet 6-35 months',
        'is_required': true,
        'age_group': '6-35',
        'display_order': 3,
      },
      {
        'question': 'Yesterday, did the child eat Grains/roots/tubers?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 6-35 months',
        'is_required': true,
        'age_group': '6-35',
        'display_order': 4,
      },
      {
        'question': 'Yesterday, did the child eat Pulses/legumes?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 6-35 months',
        'is_required': true,
        'age_group': '6-35',
        'display_order': 5,
      },
      {
        'question': 'Yesterday, did the child eat Dairy products?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 6-35 months',
        'is_required': true,
        'age_group': '6-35',
        'display_order': 6,
      },
      {
        'question': 'Yesterday, did the child eat Eggs?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 6-35 months',
        'is_required': true,
        'age_group': '6-35',
        'display_order': 7,
      },
      {
        'question': 'Yesterday, did the child eat Flesh foods?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 6-35 months',
        'is_required': true,
        'age_group': '6-35',
        'display_order': 8,
      },
      {
        'question': 'Yesterday, did the child eat Fruits & vegetables?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 6-35 months',
        'is_required': true,
        'age_group': '6-35',
        'display_order': 9,
      },
      {
        'question': 'Yesterday, did the child receive Breast milk?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 6-35 months',
        'is_required': true,
        'age_group': '6-35',
        'display_order': 10,
      },
      {
        'question': 'Does the child receive Take Home Ration (THR) from the Anganwadi Centre?',
        'type': 'single_select',
        'options': ['Yes, regularly', 'Yes, irregularly', 'No'],
        'category': 'Diet 6-35 months',
        'is_required': true,
        'age_group': '6-35',
        'display_order': 11,
      },
      {
        'question': 'If yes, how is the THR usually used?',
        'type': 'single_select',
        'options': ['Given mainly to the child', 'Shared with family', 'Occasionally used for the child', 'Other'],
        'category': 'Diet 6-35 months',
        'is_required': false,
        'age_group': '6-35',
        'display_order': 12,
      },
      {
        'question': 'How is the Take Home Ration (Pushti) usually prepared or given to the child at home?',
        'type': 'single_select',
        'options': ['Given as a thin porridge by boiling in water only', 'Prepared as thick porridge / cooked properly', 'Made into laddu, burfi, dosa, or other food items', 'Mixed with milk or other foods', 'Do not know how to prepare / rarely used for the child'],
        'category': 'Diet 6-35 months',
        'is_required': false,
        'age_group': '6-35',
        'display_order': 13,
      },
      {
        'question': 'In the past 7 days, approximately how much money was spent on junk or packaged foods for the child?',
        'type': 'single_select',
        'options': ['₹0', '₹1–50', '₹51–100', '₹101–250', 'More than ₹250'],
        'category': 'Diet 6-35 months',
        'is_required': true,
        'age_group': '6-35',
        'display_order': 14,
      },

      // Section: Child Diet, Feeding Practices & ICDS Services (36-59 months)
      {
        'question': 'Yesterday, how many times did the child eat any food (meals or snacks), including food from Anganwadi and at home?',
        'type': 'single_select',
        'options': ['0–2 times', '3 times', '4 or more times'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 1,
      },
      {
        'question': 'Yesterday, did the child eat Grains/roots/tubers?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 2,
      },
      {
        'question': 'Yesterday, did the child eat Pulses/legumes?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 3,
      },
      {
        'question': 'Yesterday, did the child eat Dairy products?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 4,
      },
      {
        'question': 'Yesterday, did the child eat Eggs?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 5,
      },
      {
        'question': 'Yesterday, did the child eat Flesh foods?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 6,
      },
      {
        'question': 'Yesterday, did the child eat Fruits & vegetables?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 7,
      },
      {
        'question': 'Yesterday, did the child receive Breast milk?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 8,
      },
      {
        'question': 'In the last 7 days, on how many days did the child attend the Anganwadi Centre?',
        'type': 'single_select',
        'options': ['0 days', '1–2 days', '3–4 days', '5–6 days'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 9,
      },
      {
        'question': 'In the last 7 days, on how many days did the child eat the hot cooked lunch provided at the Anganwadi Centre?',
        'type': 'single_select',
        'options': ['0 days', '1–2 days', '3–4 days', '5–6 days'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 10,
      },
      {
        'question': 'In the last 7 days, on how many days did the child receive breakfast at the Anganwadi Centre?',
        'type': 'single_select',
        'options': ['0 days', '1–2 days', '3–4 days', '5–6 days'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 11,
      },
      {
        'question': 'In the last 7 days, how many eggs did the child receive from the Anganwadi Centre?',
        'type': 'single_select',
        'options': ['0', '1', '2', 'More than 2'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 12,
      },
      {
        'question': 'In the last 1 month, did you face any quality-related issues with Anganwadi food?',
        'type': 'multi_select',
        'options': ['No issues', 'Food quantity was insufficient for the child', 'Food was not fresh / had quality issues', 'Child did not like the taste and refused to eat', 'Eggs were of poor quality', 'Other'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 13,
      },
      {
        'question': 'On days when the child attends the Anganwadi, does the child usually eat the food provided there?',
        'type': 'single_select',
        'options': ['Yes, eats most of it', 'Eats some, but not fully', 'Rarely eats the Anganwadi food'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 14,
      },
      {
        'question': 'When the child eats food at the Anganwadi, how does this usually affect food given at home?',
        'type': 'single_select',
        'options': ['Home meals are reduced', 'Home meals remain the same', 'Home meals are increased'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 15,
      },
      {
        'question': 'In the last 7 days, approximately how much money was spent on junk or packaged foods for the child?',
        'type': 'single_select',
        'options': ['₹0', '₹1–50', '₹51–100', '₹101–250', 'More than ₹250'],
        'category': 'Diet 36-59 months',
        'is_required': true,
        'age_group': '36-59',
        'display_order': 16,
      },

      // Section: Child Health
      {
        'question': 'In the last two weeks, has the child had diarrhoea?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Child Health',
        'is_required': true,
        'age_group': 'all',
        'display_order': 1,
      },
      {
        'question': 'In the last two weeks, has the child had cough with fast or difficult breathing?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Child Health',
        'is_required': true,
        'age_group': 'all',
        'display_order': 2,
      },
      {
        'question': 'When the child is sick, do you usually continue feeding and breastfeeding?',
        'type': 'single_select',
        'options': ['Yes, same or more', 'Yes, but less than usual', 'No, feeding is stopped', 'Don\'t know'],
        'category': 'Child Health',
        'is_required': true,
        'age_group': 'all',
        'display_order': 3,
      },

      // Section: Child Nutrition (Anthropometric measurements)
      {
        'question': 'Child\'s weight (in kg)',
        'type': 'number_input',
        'options': [],
        'category': 'Child Nutrition',
        'is_required': true,
        'age_group': 'all',
        'display_order': 1,
        'input_type': 'decimal',
      },
      {
        'question': 'Child\'s height/length (in cm)',
        'type': 'number_input',
        'options': [],
        'category': 'Child Nutrition',
        'is_required': true,
        'age_group': 'all',
        'display_order': 2,
        'input_type': 'decimal',
      },
      {
        'question': 'Child\'s Mid-Upper Arm Circumference (in cm)',
        'type': 'number_input',
        'options': [],
        'category': 'Child Nutrition',
        'is_required': true,
        'age_group': 'all',
        'display_order': 3,
        'input_type': 'decimal',
      },

      // Additional household questions not covered in registration
      {
        'question': 'What type of cooking fuel does the household mainly use?',
        'type': 'single_select',
        'options': ['LPG / PNG', 'Electricity', 'Firewood', 'Cow dung / crop residue', 'Other'],
        'category': 'Household',
        'is_required': true,
        'age_group': 'all',
        'display_order': 1,
      },
      {
        'question': 'Does the household have access to a sanitation facility (toilet), and is water available inside?',
        'type': 'single_select',
        'options': ['Toilet within household with water connection inside', 'Toilet within household without water connection inside', 'Shared toilet with water connection inside', 'Shared toilet without water connection inside', 'No toilet / open defecation'],
        'category': 'Household',
        'is_required': true,
        'age_group': 'all',
        'display_order': 2,
      },
      {
        'question': 'Main source of drinking water for the household',
        'type': 'single_select',
        'options': ['Piped water into dwelling/yard', 'Public tap / standpipe', 'Handpump / borewell', 'Protected well', 'Surface water (river, pond, etc.)', 'Other'],
        'category': 'Household',
        'is_required': true,
        'age_group': 'all',
        'display_order': 3,
      },
      {
        'question': 'Is there a handwashing facility with soap and water available in the household?',
        'type': 'single_select',
        'options': ['Yes', 'No'],
        'category': 'Household',
        'is_required': true,
        'age_group': 'all',
        'display_order': 4,
      },
      {
        'question': 'Does the household have a BPL / ration card?',
        'type': 'single_select',
        'options': ['Yes', 'No', 'Don\'t know'],
        'category': 'Household',
        'is_required': true,
        'age_group': 'all',
        'display_order': 5,
      },
      {
        'question': 'Does the household usually receive food grains from the Public Distribution System (PDS) as per norms?',
        'type': 'single_select',
        'options': ['Yes, regularly', 'Yes, but irregularly / partially', 'No', 'Don\'t know'],
        'category': 'Household',
        'is_required': true,
        'age_group': 'all',
        'display_order': 6,
      },
    ];

    print('🌱 Starting baseline questions seeding...');

    for (var question in baselineQuestions) {
      await _upsertQuestion(question, projectDocId);
    }

    print('✅ Baseline questions seeding completed!');
  }

  static Future<void> _upsertQuestion(Map<String, dynamic> question, String projectDocId) async {
    final aw = AppwriteService.I;
    
    try {
      final key = question['question']
          .toString()
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll('?', '')
          .replaceAll(',', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll('/', '_');

      // Check if question already exists
      final existing = await aw.list(
        collectionId: Constants.colQuestions,
        queries: [
          Query.equal('key', key),
          Query.equal('project', projectDocId),
          Query.limit(1),
        ],
      );

      Map<String, dynamic> questionData = {
        'key': key,
        'project': projectDocId,
        'question': question['question'],
        'type': question['type'],
        'options': question['options'] ?? [],
        'category': question['category'] ?? 'General',
        'is_required': question['is_required'] ?? false,
        'age_group': question['age_group'] ?? 'all',
        'display_order': question['display_order'] ?? 1,
        'phase': Constants.phaseBaseline,
      };

      // Add input_type for number inputs
      if (question['input_type'] != null) {
        questionData['input_type'] = question['input_type'];
      }

      if (existing.documents.isNotEmpty) {
        await aw.update(
          collectionId: Constants.colQuestions,
          documentId: existing.documents.first.$id,
          data: questionData,
        );
        print(' Updated baseline question: ${question['question']}');
      } else {
        await aw.create(
          collectionId: Constants.colQuestions,
          documentId: ID.unique(),
          data: questionData,
        );
        print(' Created baseline question: ${question['question']}');
      }
    } catch (e) {
      print(' Error seeding baseline question: ${question['question']} - $e');
    }
  }
}