import 'package:appwrite/appwrite.dart';
import '../utils/constants.dart';
import 'appwrite_service.dart';

class ChildService {
  ChildService._();
  static final ChildService I = ChildService._();

  Future<List<Map<String, dynamic>>> listChildren(String projectId) async {
    final res = await AppwriteService.I.list(
      collectionId: Constants.colChildren,
      queries: [Query.equal('project', projectId)],
    );
    return res.documents.map((d) => {'id': d.$id, ...d.data}).toList();
  }

  Future<String> createChild({
    required String projectId,
    required String name,
    required String gender,
    required DateTime dob,
    required String guardianName,
    required String guardianContact,
  }) async {
    final doc = await AppwriteService.I.create(
      collectionId: Constants.colChildren,
      data: {
        'project': projectId,
        'name': name,
        'gender': gender,
        'date_of_birth': dob.toIso8601String(),
        'guardian_name': guardianName,
        'guardian_contact': guardianContact,
      },
    );
    return doc.$id;
  }
}