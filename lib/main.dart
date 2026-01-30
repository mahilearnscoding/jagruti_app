import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:appwrite/appwrite.dart';

import 'services/appwrite_service.dart';
import 'utils/constants.dart';
import 'utils/kannada_baseline_seeder.dart';
import 'models/baseline_seeder.dart';
import 'models/counselling_seeder.dart';
import 'models/endline_seeder.dart';
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
  await Hive.openBox('counselling_visits_local');
  await Hive.openBox('counselling_responses_local');

  AppwriteService.I.init();

  // FORCE LOGIN AS SEEDER ACCOUNT FOR ALL DATABASE OPERATIONS
  try {
    await AppwriteService.I.ensureSession();
    print("🔑 SEEDER SESSION ESTABLISHED FOR DATABASE ACCESS");
  } catch (e) {
    print("🔑 SEEDER LOGIN ERROR: $e");
    print("❌ APP MAY NOT WORK WITHOUT PROPER DATABASE PERMISSIONS");
  }

  // Don't block app launch on seeding
  runApp(const JagrutiApp());

  // TEMPORARILY DISABLED SEEDING - WILL FIX AFTER DEMO
  // Seed in background; if it fails, log and continue
  /*
  try {
    const projectDocId = "6970934c003c641b26dc";
    
    // Skip baseline seeding - Kannada questions already exist in database
    print("📝 Skipping baseline seeding - using existing Kannada questions");
    
    // Seed counselling questions
    final counsellingSeeder = CounsellingSeeder(
      aw: AppwriteService.I,
      projectDocId: projectDocId,
    );
    await counsellingSeeder.seedCounselling();
    print("✅ Counselling questions seeded");
    
    // Seed endline questions
    final endlineSeeder = EndlineSeeder(
      aw: AppwriteService.I,
      projectDocId: projectDocId,
    );
    await endlineSeeder.seedEndline();
    print("✅ Endline questions seeded");
    
    // Debug question counts
    await debugQuestionCounts(projectDocId);
  } catch (e) {
    print("⚠️ Seed failed (app still runs): $e");
  }
  */
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
