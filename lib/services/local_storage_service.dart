import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService I = LocalStorageService._();

  Box get _box => Hive.box('session');

  bool get isLoggedIn => _box.get('fw_id') != null;
  String? get fieldWorkerId => _box.get('fw_id');

  Future<void> saveSession({required String fwId, required String phone}) async {
    await _box.put('fw_id', fwId);
    await _box.put('fw_phone', phone);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}