import 'package:appwrite/appwrite.dart';
import '../utils/constants.dart';

class AuthService {
  final Client client = Client()
      .setEndpoint(Constants.appwriteEndpoint)
      .setProject(Constants.appwriteProjectId);

  late final Account account;

  AuthService() {
    account = Account(client);
  }

  // FAKE SEND OTP (for development)
  Future<void> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // FAKE VERIFY OTP (Creates a proper user session for seeding)
  Future<void> verifyOtp(String otp) async {
    try {
      // For development: create a temporary user with phone number that has write permissions
      final userId = 'phone_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create user account programmatically
      await account.create(
        userId: userId,
        email: '$userId@jagruti.dev',
        password: 'temppass123',
        name: 'Field Worker',
      );
      
      // Login with created account
      await account.createEmailPasswordSession(
        email: '$userId@jagruti.dev',
        password: 'temppass123',
      );
      
      print("✅ User session created for seeding: $userId");
    } catch (e) {
      // If creation fails (user might exist), try to login with existing temp account
      try {
        await account.createEmailPasswordSession(
          email: 'seeder@jagruti.dev',
          password: 'jagruti123',
        );
        print("✅ Using existing seeder account");
      } catch (e2) {
        // Last resort: anonymous (limited permissions)
        try {
          await account.createAnonymousSession();
          print("⚠️ Using anonymous session (seeding may fail)");
        } catch (e3) {
          print("Already logged in or error: $e3");
        }
      }
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