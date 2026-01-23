import 'package:appwrite/appwrite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../utils/constants.dart';
import 'appwrite_service.dart';
import 'sync_queue_service.dart';

class ChildService {
  ChildService._();
  static final ChildService I = ChildService._();

  static const String jobCreateChild = 'CREATE_CHILD';
  static const String jobMarkBaselineSubmitted = 'MARK_BASELINE_SUBMITTED';

  /// Returns children for a project as a merged list:
  /// - local-first (offline saved)
  /// - then server list if online works
  /// Dedupe by 'id'
  Future<List<Map<String, dynamic>>> listChildren(String projectId) async {
    final localBox = Hive.box('children_local');

    // 1) local children
    final local = <Map<String, dynamic>>[];
    for (final key in localBox.keys) {
      final c = Map<String, dynamic>.from(localBox.get(key));
      if (c['project'] == projectId) {
        local.add(c);
      }
    }

    // 2) server children (best-effort)
    final server = <Map<String, dynamic>>[];
    try {
      await AppwriteService.I.ensureSession();
      final res = await AppwriteService.I.list(
        collectionId: Constants.colChildren,
        queries: [
          Query.equal('project', projectId),
          Query.limit(200),
        ],
      );
      server.addAll(res.documents.map((d) => {'id': d.$id, ...d.data}).toList());
    } catch (_) {
      // offline or unauthorized: ignore server
    }

    // 3) merge/dedupe (local wins)
    final map = <String, Map<String, dynamic>>{};
    for (final s in server) {
      final id = s['id']?.toString();
      if (id != null) map[id] = s;
    }
    for (final l in local) {
      final id = l['id']?.toString();
      if (id != null) map[id] = l;
    }

    final merged = map.values.toList();

    // Optional: sort by createdAt (fallback to name)
    merged.sort((a, b) {
      final ca = a['createdAt']?.toString() ?? '';
      final cb = b['createdAt']?.toString() ?? '';
      return cb.compareTo(ca);
    });

    return merged;
  }

  /// Local-first create child (offline-safe)
  /// Returns childId immediately (UUID).
  Future<String> createChildLocal({
    required String projectId,
    required String name,
    required String gender,
    required DateTime dob,
    required String guardianName,
    required String guardianContact,
  }) async {
    final childId =  Uuid().v4();
    final box = Hive.box('children_local');

    final data = <String, dynamic>{
      'id': childId,
      'project': projectId,
      'name': name,
      'gender': gender,
      'date_of_birth': dob.toIso8601String(),
      'guardian_name': guardianName,
      'guardian_contact': guardianContact,
      'baselineStatus': 'draft',
      'baselineVisitId': null,
      'createdAt': DateTime.now().toIso8601String(),
      'synced': false,
    };

    // save locally
    box.put(childId, data);

    //enqueue sync job
    SyncQueueService.I.enqueue({
      'type': jobCreateChild,
      'childId': childId,
      'data': {
        'project': projectId,
        'name': name,
        'gender': gender,
        'date_of_birth': dob.toIso8601String(),
        'guardian_name': guardianName,
        'guardian_contact': guardianContact,
        'baselineStatus': 'draft',
      },
    });

    return childId;
  }

  //mark baseline submitted locally and queue server update
  Future<void> markBaselineSubmittedLocal({
    required String childId,
    required String visitId,
  }) async {
    final box = Hive.box('children_local');
    final existing = box.get(childId);
    if (existing != null) {
      final c = Map<String, dynamic>.from(existing);
      c['baselineStatus'] = 'submitted';
      c['baselineVisitId'] = visitId;
      c['synced'] = false;
      box.put(childId, c);
    }

    SyncQueueService.I.enqueue({
      'type': jobMarkBaselineSubmitted,
      'childId': childId,
      'visitId': visitId,
    });
  }
}
