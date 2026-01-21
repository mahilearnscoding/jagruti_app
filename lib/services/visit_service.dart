import '../utils/constants.dart';
import 'appwrite_service.dart';

class VisitService {
  VisitService._();
  static final VisitService I = VisitService._();

  Future<String> createVisit({required String childId, required String phase, required String fwId}) async {
    final doc = await AppwriteService.I.create(
      collectionId: Constants.colVisits,
      data: {
        'child': childId,
        'created_by': fwId,
        'phase': phase,
        'visit_date': DateTime.now().toIso8601String(),
      },
    );
    return doc.$id;
  }

  Future<void> saveAnswer({required String visitId, required String questionId, required dynamic value}) async {
    await AppwriteService.I.create(
      collectionId: Constants.colVisitAnswers,
      data: {
        'visit': visitId,
        'question': questionId,
        'answer_text': value.toString(),
      },
    );
  }
}