import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'sync_queue_service.dart';

class VisitService {
  VisitService._();
  static final VisitService I = VisitService._();

  static const String jobCreateVisit = 'CREATE_VISIT';
  static const String jobUpsertVisitAnswer = 'UPSERT_VISIT_ANSWER';

  /// Local-first visit create (offline-safe)
  Future<String> createVisitLocal({
    required String childId,
    required String phase,
    required String fwId,
  }) async {
    final visitId = const Uuid().v4();
    final nowIso = DateTime.now().toIso8601String();

    // Required by your visits schema (pilot placeholders)
    const double lat = 0.0;
    const double lng = 0.0;
    const String photoUrl = "";

    // Save locally
    final visitsBox = Hive.box('visits_local');
    visitsBox.put(visitId, {
      'id': visitId,
      'child': childId,
      'created_by': fwId,
      'phase': phase,
      'visit_date': nowIso,
      'latitude': lat,
      'longitude': lng,
      'photo_url': photoUrl,
    });

    // Queue sync
    SyncQueueService.I.enqueue({
      'type': jobCreateVisit,
      'visitId': visitId,
      'data': {
        'child': childId,
        'created_by': fwId,
        'phase': phase,
        'visit_date': nowIso,
        'latitude': lat,
        'longitude': lng,
        'photo_url': photoUrl,
      }
    });

    return visitId;
  }

  /// Local-first answer save (offline-safe)
  Future<void> saveAnswerLocal({
    required String visitId,
    required String questionId,
    required dynamic value,
  }) async {
    final answerKey = '$visitId|$questionId';

    // Save locally
    final answersBox = Hive.box('visit_answers_local');
    answersBox.put(answerKey, {
      'visit': visitId,
      'question': questionId,
      'answer_text': value?.toString() ?? '',
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Deterministic docId so retries don't duplicate answers
    // NOTE: your uuid version expects namespace as String -> use Uuid.NAMESPACE_URL
    final answerDocId = const Uuid().v5(Uuid.NAMESPACE_URL, answerKey);

    SyncQueueService.I.enqueue({
      'type': jobUpsertVisitAnswer,
      'answerDocId': answerDocId,
      'data': {
        'visit': visitId,
        'question': questionId,
        'answer_text': value?.toString() ?? '',
      }
    });
  }

  /// Local-only marker (no server update because visits schema doesn't have status)
  Future<void> markVisitSubmittedLocal({required String visitId}) async {
    final visitsBox = Hive.box('visits_local');
    final existing = visitsBox.get(visitId);
    if (existing != null) {
      final v = Map<String, dynamic>.from(existing);
      v['local_status'] = 'submitted';
      v['submittedAt'] = DateTime.now().toIso8601String();
      visitsBox.put(visitId, v);
    }
  }
}
