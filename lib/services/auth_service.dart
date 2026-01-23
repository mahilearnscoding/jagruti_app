import 'package:appwrite/appwrite.dart';

class AuthService {
  final Client client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('696a60cf00151d14bf35'); // Your Project ID

  late final Account account;

  AuthService() {
    account = Account(client);
  }

  // FAKE SEND OTP (Bypasses the limit error)
  Future<void> sendOtp(String phoneNumber) async {
    // We don't actually call Appwrite here anymore.
    // We just pretend to wait for 1 second.
    await Future.delayed(const Duration(seconds: 1));
  }

  // FAKE VERIFY OTP (Actually does Anonymous Login)
  Future<void> verifyOtp(String otp) async {
    // We ignore the OTP code.
    // Instead, we create an "Anonymous Session" so the app works.
    try {
      await account.createAnonymousSession();
    } catch (e) {
      // If we are already logged in, just continue
      print("Already logged in or error: $e");
    }
  }

  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
  }
}
/*import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AuthService {
  // 1. SETUP THE CLIENT (Do this right here to be safe)
  final Client client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1') // Your API Endpoint
      .setProject('696a5e940026621a01ee');              // <--- REPLACE THIS!!!

  late final Account account;

  // We store the userId temporarily so we can verify the OTP later
  static String? _tempUserId;

  AuthService() {
    account = Account(client);
  }

  // 2. SEND OTP
  Future<void> sendOtp(String phoneNumber) async {
    try {
      // Appwrite demands international format: +919999999999
      final token = await account.createPhoneToken(
        userId: ID.unique(),
        phone: '+91$phoneNumber', 
      );
      _tempUserId = token.userId; // Save this ID! We need it for step 2.
    } catch (e) {
      throw Exception("Failed to send OTP: $e");
    }
  }

  // 3. VERIFY OTP
  Future<models.Session> verifyOtp(String otp) async {
    if (_tempUserId == null) throw Exception("Something went wrong. Please request OTP again.");
    
    try {
      final session = await account.updatePhoneSession(
        userId: _tempUserId!,
        secret: otp,
      );
      return session;
    } catch (e) {
      throw Exception("Invalid OTP. Please try again.");
    }
  }
}*/