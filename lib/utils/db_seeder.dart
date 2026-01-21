import '../services/appwrite_service.dart';
import '../utils/constants.dart';

class DatabaseSeeder {
  // ⚠️ TODO: Replace this with your actual Project ID from Appwrite Console
  final String projectId = '696a5e940026621a01ee';

  final List<Map<String, dynamic>> baselineQuestions = [
    // --- SECTION 1: HOUSEHOLD INFO (1-17) ---
    {
      'key': 'hh_head_name',
      'text': '1. Name of head of household',
      'type': 'text',
      'is_required': true,
    },
    {
      'key': 'hh_head_gender',
      'text': '2. Gender of head of household',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Male', 'Female', 'Other']
    },
    {
      'key': 'hh_member_count',
      'text': '3. Total number of members in household',
      'type': 'single_choice',
      'is_required': true,
      'options': ['1-3', '4-5', '6-7', '8+']
    },
    {
      'key': 'hh_caste',
      'text': '4. Social group / caste',
      'type': 'single_choice',
      'is_required': true,
      'options': ['SC', 'ST', 'OBC', 'General', 'Other']
    },
    {
      'key': 'hh_occupation',
      'text': '5. Primary occupation of household',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Agriculture', 'Daily Wage', 'Salaried', 'Self Employed', 'Unemployed']
    },
    {
      'key': 'hh_migration',
      'text': '6. Does any parent migrate for work?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['No', 'Father only', 'Mother only', 'Both']
    },
    {
      'key': 'hh_mgnrega',
      'text': '7. Does household have MGNREGA job card?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Yes', 'No', 'Dont Know']
    },
    {
      'key': 'hh_dust',
      'text': '8. Is there a lot of dust around the house?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['High', 'Medium', 'Low', 'None']
    },
    {
      'key': 'hh_lit_mother',
      'text': '9. Literacy status of mother',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Cannot read write', 'Can read write', 'Primary School', 'High School+']
    },
    {
      'key': 'hh_lit_father',
      'text': '10. Literacy status of father',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Cannot read write', 'Can read write', 'Primary School', 'High School+']
    },
    {
      'key': 'hh_fuel',
      'text': '11. Main cooking fuel',
      'type': 'single_choice',
      'is_required': true,
      'options': ['LPG', 'Firewood', 'Kerosene', 'Electric', 'Other']
    },
    {
      'key': 'hh_toilet',
      'text': '12. Toilet facility',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Private Latrine', 'Shared Latrine', 'Open Defecation']
    },
    {
      'key': 'hh_water_src',
      'text': '13. Main source of drinking water',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Piped Water', 'Handpump', 'Well', 'River Pond', 'Other']
    },
    {
      'key': 'hh_soap',
      'text': '14. Handwashing facility with soap available?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Yes', 'No']
    },
    {
      'key': 'hh_diet_type',
      'text': '15. Household dietary pattern',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Vegetarian', 'Non Vegetarian', 'Eggetarian']
    },
    {
      'key': 'hh_ration',
      'text': '16. Has Ration Card / BPL Card?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Yes', 'No']
    },
    {
      'key': 'hh_pds',
      'text': '17. Receives PDS grains regularly?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Yes Regular', 'Yes Irregular', 'No']
    },

    // --- SECTION 2: MOTHER DETAILS (18-24) ---
    {
      'key': 'mo_name',
      'text': '18. Mother Name',
      'type': 'text',
      'is_required': true,
    },
    {
      'key': 'mo_age',
      'text': '19. Mother Age (years)',
      'type': 'number',
      'is_required': true,
    },
    {
      'key': 'mo_village',
      'text': '20. Village Name',
      'type': 'text',
      'is_required': true,
    },
    {
      'key': 'mo_education',
      'text': '21. Mother Education Level',
      'type': 'single_choice',
      'is_required': true,
      'options': ['None', 'Primary', 'Secondary', 'Graduate']
    },
    {
      'key': 'mo_anaemia',
      'text': '22. Mother Anaemia Status (Health Card)',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Normal', 'Mild', 'Moderate', 'Severe', 'Unknown']
    },
    {
      'key': 'mo_occ',
      'text': '23. Mother Occupation',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Homemaker', 'Laborer', 'Salaried', 'Self Employed']
    },
    {
      'key': 'mo_decision',
      'text': '24. Who takes major household decisions?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Mother', 'Father', 'Both Jointly', 'Grandparents']
    },

    // --- SECTION 3: CHILD DETAILS (25-32) ---
    // (Note: Name, DOB, Gender are collected in "Add Child Screen", so we skip them here to avoid duplicates)
    {
      'key': 'ch_birth_order',
      'text': '29. Birth Order of this child',
      'type': 'number',
      'is_required': true,
    },
    {
      'key': 'ch_caregiver',
      'text': '30. Primary Caregiver',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Mother', 'Father', 'Grandparent', 'Sibling', 'Other']
    },
    {
      'key': 'ch_interaction',
      'text': '31. Hours spent with child daily',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Less than 1 hr', '1-2 hrs', 'More than 2 hrs']
    },
    {
      'key': 'ch_awc_enroll',
      'text': '32. Is child enrolled in Anganwadi?',
      'type': 'single_choice',
      'is_required': true,
      'options': ['Yes', 'No']
    },

    // --- SECTION 4A: DIET 6-35 MONTHS (33-40) ---
    {
      'key': 'diet_start_solids',
      'text': '33. Age started semi-solid food (months)',
      'type': 'single_choice',
      'is_required': false,
      'options': ['Before 6m', '6-8m', 'After 8m']
    },
    {
      'key': 'diet_consistency',
      'text': '34. Consistency of food',
      'type': 'single_choice',
      'is_required': false,
      'options': ['Watery', 'Semi-solid', 'Solid']
    },
    {
      'key': 'diet_freq',
      'text': '35. Times ate yesterday',
      'type': 'number',
      'is_required': false,
    },
    {
      'key': 'diet_groups',
      'text': '36. Food groups eaten yesterday',
      'type': 'multi_choice',
      'is_required': false,
      'options': ['Grains', 'Pulses', 'Milk', 'Eggs', 'Meat', 'Fruits Veg']
    },
    {
      'key': 'diet_thr',
      'text': '37. Received Take Home Ration (THR)?',
      'type': 'single_choice',
      'is_required': false,
      'options': ['Regularly', 'Irregularly', 'No']
    },
    {
      'key': 'diet_thr_use',
      'text': '38. Who consumes the THR?',
      'type': 'single_choice',
      'is_required': false,
      'options': ['Child only', 'Shared with family', 'Not used']
    },
     {
      'key': 'diet_junk',
      'text': '40. Money spent on junk food last week',
      'type': 'number',
      'is_required': false,
    },

    // --- SECTION 4B: DIET 36-59 MONTHS (41-51) ---
    {
      'key': 'diet_ch_freq',
      'text': '41. Times ate yesterday (Child 3-5y)',
      'type': 'number',
      'is_required': false,
    },
    {
      'key': 'diet_awc_days',
      'text': '44. Days attended Anganwadi last week',
      'type': 'number',
      'is_required': false,
    },
    {
      'key': 'diet_awc_meal',
      'text': '45. Days ate hot meal at Anganwadi',
      'type': 'number',
      'is_required': false,
    },
     {
      'key': 'diet_awc_eggs',
      'text': '47. Eggs received at Anganwadi last week',
      'type': 'number',
      'is_required': false,
    },

    // --- SECTION 5: HEALTH & ANTHROPOMETRY (52-56) ---
    {
      'key': 'hlth_illness',
      'text': '52. Illness in last 2 weeks',
      'type': 'multi_choice',
      'is_required': true,
      'options': ['None', 'Fever', 'Cough', 'Diarrhea', 'Vomiting']
    },
    {
      'key': 'hlth_feeding_sick',
      'text': '53. Feeding during illness',
      'type': 'single_choice',
      'is_required': true,
      'options': ['More than usual', 'Same', 'Less', 'Stopped']
    },
    {
      'key': 'nut_weight',
      'text': '54. Weight (kg)',
      'type': 'decimal',
      'is_required': true,
      'is_anthropometric': true
    },
    {
      'key': 'nut_height',
      'text': '55. Height (cm)',
      'type': 'decimal',
      'is_required': true,
      'is_anthropometric': true
    },
    {
      'key': 'nut_muac',
      'text': '56. MUAC (cm)',
      'type': 'decimal',
      'is_required': true,
      'is_anthropometric': true
    }
  ];

  Future<void> seed() async {
    final aw = AppwriteService.I;
    int order = 1;

    print("🌱 Starting Seeder...");

    for (var q in baselineQuestions) {
      try {
        print("Processing: ${q['text']}");

        // 1. Create Question in 'questions' collection
        final qDoc = await aw.create(
          collectionId: Constants.colQuestions,
          data: {
            'question_key': q['key'],
            'question_text': q['text'],
            'answer_type': q['type'],
            'is_active': true,
            'is_anthropometric': q['is_anthropometric'] ?? false,
          },
        );

        // 2. Create Options (if single_choice or multi_choice)
        if (q['options'] != null) {
          int optOrder = 1;
          for (String optLabel in q['options']) {
            await aw.create(
              collectionId: Constants.colQuestionOptions,
              data: {
                'question': qDoc.$id,
                'option_label': optLabel,
                'option_value': optLabel.toLowerCase().replaceAll(' ', '_'), // e.g. "Male" -> "male"
                'display_order': optOrder++,
              },
            );
          }
        }

        // 3. Link to Project in 'project_questions' collection
        await aw.create(
          collectionId: Constants.colProjectQuestions,
          data: {
            'project': projectId,
            'question': qDoc.$id,
            'phase': Constants.phaseBaseline, // e.g. 'baseline'
            'is_required': q['is_required'] ?? false,
            'display_order': order++,
          },
        );

      } catch (e) {
        print("❌ Error on ${q['key']}: $e");
      }
    }
    print("✅ Seeding Complete!");
  }
}