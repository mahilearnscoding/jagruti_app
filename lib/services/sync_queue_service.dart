import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class SyncQueueService {
  SyncQueueService._();
  static final SyncQueueService I = SyncQueueService._();

  void enqueue(Map<String, dynamic> job) {
    final box = Hive.box('sync_queue');
    final id =  Uuid().v4();
    box.put(id, {
      'id': id,
      ...job,
      'createdAt': DateTime.now().toIso8601String(),
      'retryCount': 0,
      'lastError': null,
    });
  }
}
