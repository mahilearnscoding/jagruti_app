import 'package:appwrite/appwrite.dart';
import '../utils/constants.dart';
import 'appwrite_service.dart';

// 1. Define the QuestionBundle class
class QuestionBundle {
  final String questionId;
  final String text;
  final String type;
  final bool isRequired;
  final List<Map<String, String>> options;

  QuestionBundle({
    required this.questionId, 
    required this.text, 
    required this.type, 
    required this.isRequired, 
    required this.options
  });
}

// 2. Define the QuestionService class
class QuestionService {
  QuestionService._();
  static final QuestionService I = QuestionService._();

  Future<List<QuestionBundle>> getBaselineQuestions(String projectId) async {
    final aw = AppwriteService.I;
    
    // Get the list of questions for this project
    final pqRes = await aw.list(
      collectionId: Constants.colProjectQuestions,
      queries: [
        Query.equal('project', projectId),
        Query.equal('phase', Constants.phaseBaseline),
        Query.orderAsc('display_order'),
      ],
    );

    List<QuestionBundle> bundles = [];

    // Loop through and get details
    for (var doc in pqRes.documents) {
      final qId = aw.relId(doc.data['question']);
      if (qId == null) continue;

      // Get Question Text
      final qDoc = await aw.get(collectionId: Constants.colQuestions, documentId: qId);
      
      // Get Options (if any)
      List<Map<String, String>> options = [];
      String type = qDoc.data['answer_type'] ?? 'text';
      
      if (['single_choice', 'multi_choice', 'single_select'].contains(type)) {
        final optRes = await aw.list(
          collectionId: Constants.colQuestionOptions,
          queries: [Query.equal('question', qId), Query.orderAsc('display_order')],
        );
        options = optRes.documents.map((o) => {
          'value': o.data['option_value'].toString(),
          'label': o.data['option_label'].toString()
        }).toList();
      }

      bundles.add(QuestionBundle(
        questionId: qId,
        text: qDoc.data['question_text'] ?? 'Unknown Question',
        type: type,
        isRequired: doc.data['is_required'] ?? false,
        options: options,
      ));
    }
    return bundles;
  }
}