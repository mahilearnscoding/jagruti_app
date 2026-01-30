import 'package:appwrite/appwrite.dart';
import '../utils/constants.dart';
import 'appwrite_service.dart';

class QuestionBundle {
  final String questionId;
  final String text;
  final String type;
  final bool isRequired;
  final List<Map<String, String>> options;
  final String? section;
  final int? sectionOrder;
  final String? ageGroup;

  QuestionBundle({
    required this.questionId,
    required this.text,
    required this.type,
    required this.isRequired,
    required this.options,
    this.section,
    this.sectionOrder,
    this.ageGroup,
  });
}

class QuestionService {
  QuestionService._();
  static final QuestionService I = QuestionService._();

  Future<List<QuestionBundle>> getBaselineQuestions(String projectId) {
    return getQuestionsForPhase(projectId: projectId, phase: Constants.phaseBaseline);
  }

  Future<List<QuestionBundle>> getCounsellingQuestions(String projectId) {
    return getQuestionsForPhase(projectId: projectId, phase: Constants.phaseCounselling);
  }

  Future<List<QuestionBundle>> getEndlineQuestions(String projectId) {
    // For demo: endline uses same questions as baseline since endline questions not yet in DB
    return getQuestionsForPhase(projectId: projectId, phase: Constants.phaseBaseline);
  }

  Future<List<QuestionBundle>> getQuestionsForPhase({
    required String projectId,
    required String phase,
  }) async {
    final aw = AppwriteService.I;
    await aw.ensureSession();

    print('🔍 Loading questions for project: $projectId, phase: $phase');

    // Get questions from project_questions table
    final pqRes = await aw.list(
      collectionId: Constants.colProjectQuestions,
      queries: [
        Query.equal('project', projectId),
        Query.equal('phase', phase),
        Query.orderAsc('display_order'),
        Query.limit(500),
      ],
    );

    print('📊 Found ${pqRes.documents.length} project questions for phase: $phase');

    List<QuestionBundle> bundles = [];

    for (var doc in pqRes.documents) {
      // Try to get question ID from 'question' field, or extract from document ID
      String qId = aw.relId(doc.data['question']);
      
      // If question field is null/empty, try to extract from document ID
      // Document IDs look like: pq_end_q056 -> question ID might be: kn_end_q056 or similar
      if (qId.isEmpty) {
        // Try extracting question ID from the pq document ID
        final pqId = doc.$id; // e.g., "pq_end_q056"
        if (pqId.startsWith('pq_')) {
          qId = 'kn_${pqId.substring(3)}'; // Convert pq_end_q056 -> kn_end_q056
        }
      }
      
      if (qId.isEmpty) {
        print('⚠️ Skipping project_question ${doc.$id} - no question ID found');
        continue;
      }

      try {
        // Get Question Text from questions table
        final qDoc = await aw.get(
          collectionId: Constants.colQuestions,
          documentId: qId,
        );

        print('📝 Question: ${qDoc.data['question_text'] ?? qDoc.data['question'] ?? qDoc.data['text'] ?? 'No text'}');

        // Get Options (if any)
        List<Map<String, String>> options = [];
        String type = (qDoc.data['answer_type'] ?? qDoc.data['type'] ?? 'text').toString();
        print('   🏷️ Type: $type');

        if (['single_choice', 'multi_choice', 'single_select', 'select', 'radio', 'checkbox', 'multiple_choice'].contains(type)) {
          final optRes = await aw.list(
            collectionId: Constants.colQuestionOptions,
            queries: [
              Query.equal('question', qDoc.$id),
              Query.orderAsc('display_order'),
            ],
          );

          print('📋 Found ${optRes.documents.length} options for question ${qDoc.$id}');
          for (var optDoc in optRes.documents) {
            final label = optDoc.data['option_label']?.toString() ?? '';
            final value = optDoc.data['option_value']?.toString() ?? label;
            print('  📌 Option: $label');
            options.add({
              'label': label,
              'value': value,
            });
          }
        }

        bundles.add(
          QuestionBundle(
            questionId: qDoc.$id,
            text: qDoc.data['question_text']?.toString() ?? qDoc.data['question']?.toString() ?? qDoc.data['text']?.toString() ?? '',
            type: type,
            isRequired: qDoc.data['is_required'] == true,
            options: options,
            section: qDoc.data['category']?.toString() ?? qDoc.data['section']?.toString(),
            sectionOrder: qDoc.data['section_order'] as int? ?? qDoc.data['display_order'] as int? ?? 0,
          ),
        );
      } catch (e) {
        print('❌ Error loading question $qId: $e');
        continue;
      }
    }

    print('✅ Loaded ${bundles.length} Kannada questions from database');
    return bundles;

    for (var doc in pqRes.documents) {
      final qId = aw.relId(doc.data['question']);
      if (qId.isEmpty) continue;

      // get Question Text
      final qDoc = await aw.get(
        collectionId: Constants.colQuestions,
        documentId: qId,
      );

      // get Options (if any)
      List<Map<String, String>> options = [];
      String type = (qDoc.data['answer_type'] ?? 'text').toString();

      if (['single_choice', 'multi_choice', 'single_select'].contains(type)) {
        final optRes = await aw.list(
          collectionId: Constants.colQuestionOptions,
          queries: [
            Query.equal('question', qId),
            Query.orderAsc('display_order'),
          ],
        );

        options = optRes.documents
            .map((o) => {
                  'value': o.data['option_value'].toString(),
                  'label': o.data['option_label'].toString(),
                })
            .toList();
      }

      bundles.add(
        QuestionBundle(
          questionId: qId,
          text: (qDoc.data['question_text'] ?? qDoc.data['question'] ?? 'Unknown Question').toString(),
          type: type,
          isRequired: (doc.data['is_required'] ?? false) == true,
          options: options,
          section: (qDoc.data['section'] ?? qDoc.data['category'] ?? 'General').toString(),
          sectionOrder: qDoc.data['section_order'] as int?,
          ageGroup: qDoc.data['age_group']?.toString(),
        ),
      );
    }

    return bundles;
  }
}
