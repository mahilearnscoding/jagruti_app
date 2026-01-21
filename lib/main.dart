import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'services/appwrite_service.dart'; // 1. Add this import

void main() {
  // 2. Add these two lines inside main:
  WidgetsFlutterBinding.ensureInitialized(); 
  AppwriteService.I.init(); 

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF26A69A)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}