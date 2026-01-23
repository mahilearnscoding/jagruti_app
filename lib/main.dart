import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:appwrite/appwrite.dart';
import 'services/appwrite_service.dart';
import 'utils/constants.dart';

import 'screens/splash/splash_screen.dart';
import 'services/appwrite_service.dart'; // <-- change path if yours is different
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

  print("DEBUG: phaseBaseline=${Constants.phaseBaseline}");
  print("DEBUG: projectDocId=$projectDocId");
  print("DEBUG: project_questions.total=${pq.total}");
  print("DEBUG: questions.total=${q.total}");
  if (pq.documents.isNotEmpty) {
    print("DEBUG: first project_question doc=${pq.documents.first.data}");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive init + required boxes for offline-first + sync queue
  await Hive.initFlutter();
  await Hive.openBox('session');
  await Hive.openBox('children_local');
  await Hive.openBox('visits_local');
  await Hive.openBox('visit_answers_local');
  await Hive.openBox('sync_queue');

  // Appwrite init (endpoint + projectId + databaseId should be set inside)
  AppwriteService.I.init();
  await debugQuestionCounts("projects");


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
