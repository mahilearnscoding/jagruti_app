import 'dart:async';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../../services/sync_manager.dart'; // <-- adjust path if needed

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Try syncing queued offline data (won't do anything if offline)
    Future.microtask(() async {
      try {
        await SyncManager.I.trySync();
      } catch (_) {
        // ignore sync errors on splash
      }
    });

    // Wait 3 seconds, then go to Login
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "JAGRUTI",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: primary, // matches app color
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 18),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
