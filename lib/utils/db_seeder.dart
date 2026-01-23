import '../services/appwrite_service.dart';
import '../utils/constants.dart';
import 'kannada_baseline_seeder.dart';

class DatabaseSeeder {
  DatabaseSeeder._();
  static final DatabaseSeeder I = DatabaseSeeder._();

  Future<void> seed() async {
    final aw = AppwriteService.I;
    await aw.ensureSession();

    final seeder = KannadaBaselineSeeder(
      aw: aw,
      projectDocId: Constants.projectDocId,
    );

    await seeder.seedBaseline();
  }
}
