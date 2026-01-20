import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart'; // Make sure this import points to your login file

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // THE TIMER: Wait 3 seconds, then go to Login
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // If you have an image, replace Icon with Image.asset(...)
            Icon(Icons.volunteer_activism, size: 100, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text(
              "JAGRUTI",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(), // Shows the user something is loading
          ],
        ),
      ),
    );
  }
}