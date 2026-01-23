import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:appwrite/appwrite.dart';

import 'services/appwrite_service.dart';
import 'utils/constants.dart';
import 'utils/kannada_baseline_seeder.dart';
import 'screens/splash/splash_screen.dart';

Future<void> debugQuestionCounts(String projectDocId) async {
  final aw = AppwriteService.I;
  await aw.ensureSession();

  final pq = await aw.list(
    collectionId: Constants.colProjectQuestions,
    queries: [
      Query.equal('project', projectDocId),
      Query.equal('phase', Constants.phaseBaseline),
      Query.limit(5),
    ],
  );

  final q = await aw.list(
    collectionId: Constants.colQuestions,
    queries: [Query.limit(5)],
  );

  debugPrint("DEBUG: phaseBaseline=${Constants.phaseBaseline}");
  debugPrint("DEBUG: projectDocId=$projectDocId");
  debugPrint("DEBUG: project_questions.total=${pq.total}");
  debugPrint("DEBUG: questions.total=${q.total}");
  if (pq.documents.isNotEmpty) {
    debugPrint("DEBUG: first project_question doc=${pq.documents.first.data}");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('session');
  await Hive.openBox('children_local');
  await Hive.openBox('visits_local');
  await Hive.openBox('visit_answers_local');
  await Hive.openBox('sync_queue');

  AppwriteService.I.init();
  await AppwriteService.I.ensureSession();

  // Seed Kannada baseline only
  final seeder = KannadaBaselineSeeder(
    aw: AppwriteService.I,
    projectDocId: Constants.projectDocId, // <-- ROW id in projects table
  );
  await seeder.seedBaseline();

  await debugQuestionCounts(Constants.projectDocId);

  runApp(const JagrutiApp());
}

class JagrutiApp extends StatelessWidget {
  const JagrutiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jagruti Field App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
