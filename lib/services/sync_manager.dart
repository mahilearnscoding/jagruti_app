import 'package:appwrite/appwrite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/constants.dart';
import 'appwrite_service.dart';
import 'child_service.dart';
import 'visit_service.dart';

class SyncManager {
  SyncManager._();
  static final SyncManager I = SyncManager._();

  Future<bool> _isOnline() async {
  final results = await Connectivity().checkConnectivity(); 
  return results.isNotEmpty && !results.contains(ConnectivityResult.none);
}


  /// Call this on app start + after baseline submit + on "Retry Sync" button
  Future<void> trySync() async {
    if (!await _isOnline()) return;

    // Ensure session exists (anonymous ok)
    await AppwriteService.I.ensureSession();

    final queue = Hive.box('sync_queue');
    final keys = queue.keys.toList();

    // Sort by createdAt so child/visit gets created before answers
    keys.sort((a, b) {
      final ja = Map<String, dynamic>.from(queue.get(a));
      final jb = Map<String, dynamic>.from(queue.get(b));
      return (ja['createdAt'] ?? '').compareTo(jb['createdAt'] ?? '');
    });

    for (final key in keys) {
      final job = Map<String, dynamic>.from(queue.get(key));

      try {
        await _runJob(job);
        await queue.delete(key); 
      } catch (e) {
        job['retryCount'] = (job['retryCount'] ?? 0) + 1;
        job['lastError'] = e.toString();
        await queue.put(key, job); //retry
      }
    }
  }

  Future<void> _runJob(Map<String, dynamic> job) async {
    final type = job['type'] as String;

    switch (type) {
      case ChildService.jobCreateChild:
        await AppwriteService.I.create(
          collectionId: Constants.colChildren,
          documentId: job['childId'],
          data: Map<String, dynamic>.from(job['data']),
        );
        break;

      case ChildService.jobMarkBaselineSubmitted:
        await AppwriteService.I.update(
          collectionId: Constants.colChildren,
          documentId: job['childId'],
          data: {
            'baselineStatus': 'submitted',
            'baselineVisitId': job['visitId'],
          },
        );
        break;
        
      case VisitService.jobCreateVisit:
        await AppwriteService.I.create(
          collectionId: Constants.colVisits,
          documentId: job['visitId'],
          data: Map<String, dynamic>.from(job['data']),
        );
        break;

      case VisitService.jobUpsertVisitAnswer:
        final docId = job['answerDocId'] as String;
        final data = Map<String, dynamic>.from(job['data']);

        try {
          await AppwriteService.I.create(
            collectionId: Constants.colVisitAnswers,
            documentId: docId,
            data: data,
          );
        } on AppwriteException catch (e) {
          if (e.code == 409) {
            await AppwriteService.I.update(
              collectionId: Constants.colVisitAnswers,
              documentId: docId,
              data: data,
            );
          } else {
            rethrow;
          }
        }
        break;

      default:
        throw Exception('Unknown sync job type: $type');
    }
  }
}
