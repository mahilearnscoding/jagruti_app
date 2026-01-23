import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../dashboard/project_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isOtpSent = false;
  bool _isLoading = false;

  void _handleSendOtp() async {
    setState(() => _isLoading = true);
    // Call the fake sender
    await _authService.sendOtp(_phoneController.text);
    setState(() {
      _isOtpSent = true;
      _isLoading = false;
    });
  }

  void _handleVerifyOtp() async {
    setState(() => _isLoading = true);

    try {
      // Call the anonymous login
      await _authService.verifyOtp(_otpController.text);

      if (mounted) {
        // NAVIGATE TO HOME
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProjectListScreen()),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dev Mode Login Success!")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_open, size: 80, color: Colors.blue),
            const SizedBox(height: 30),
            Text(
              _isOtpSent ? "Enter OTP" : "Dev Login",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            
            if (!_isOtpSent)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
              )
            else
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "OTP"),
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : (_isOtpSent ? _handleVerifyOtp : _handleSendOtp),
              child: _isLoading 
                ? const CircularProgressIndicator()
                : Text(_isOtpSent ? "Enter App" : "Get Code"),
            ),
          ],
        ),
      ),
    );
  }
}