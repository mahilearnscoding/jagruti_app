import 'package:appwrite/appwrite.dart';

class AuthService {
  // Ensure this ID matches Constants.appwriteProjectId exactly
  final Client client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('696a5e940026621a01ee'); 

  late final Account account;

  AuthService() {
    account = Account(client);
  }

  // This is the method the compiler is looking for!
  Future<void> sendOtp(String phoneNumber) async {
    // We simulate a network delay for the dummy flow
    print("Simulating OTP send to: $phoneNumber");
    await Future.delayed(const Duration(seconds: 1));
  }

  // FAKE VERIFY OTP (Creates the necessary Session)
  Future<void> verifyOtp(String otp) async {
    try {
      // This creates the "Key" that unlocks the database
      await account.createAnonymousSession();
      print("✅ Session created successfully!");
    } catch (e) {
      // If session already exists, we just move on
      print("Session status: $e");
    }
  }

  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      print("Logout error: $e");
    }
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