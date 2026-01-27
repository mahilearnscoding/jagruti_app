import 'package:appwrite/appwrite.dart';
import '../utils/constants.dart';
import 'appwrite_service.dart';

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

  // FAKE VERIFY OTP (Uses existing seeder session)
  Future<void> verifyOtp(String otp) async {
    try {
      // Don't create a new user - just ensure we have the seeder session
      await AppwriteService.I.ensureSession();
      print("✅ Using existing seeder session for database operations");
    } catch (e) {
      print("❌ Failed to maintain seeder session: $e");
      throw Exception('Authentication failed');
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