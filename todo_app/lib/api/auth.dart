import 'client.dart';
import 'package:todo_app/models/user.dart';
import 'package:dio/dio.dart';

// A simple signal class for the UI
class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({required this.success, required this.message, this.user});
}

class AuthService {
  // 1. SIGNUP
  Future<AuthResult> signup(User user) async {
    try {
      final response = await dio.post(
        '/user/signup',
        data: user.sendSignupData(),
      );

      final userData = User.fromJson(response.data['user']);
      final token = response.data['access_token'];

      // Save token but don't set as verified (user needs to verify email)
      await userData.saveToken(token);

      return AuthResult(
        success: true,
        message:
            response.data['message'] ??
            "Signup successful! Please check your email to verify your account.",
        user: userData,
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: e.response?.data['detail'] ?? "Signup failed",
      );
    }
  }

  // 2. LOGIN
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/user/login',
        data: {'email': email, 'password': password},
      );

      final userData = User.fromJson(response.data['user']);
      final token = response.data['access_token'];

      // Save token and use server's verification status
      if (userData.is_verified) {
        await userData.saveTokenAndVerify(token);
      } else {
        await userData.saveToken(token);
      }

      return AuthResult(
        success: true,
        message: userData.is_verified
            ? "Welcome back!"
            : "Welcome back! Please verify your email to access all features.",
        user: userData,
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: e.response?.data['detail'] ?? "Login failed",
      );
    }
  }

  // 3. VERIFY (The missing piece!)
  Future<AuthResult> verify(String email, String code) async {
    try {
      final response = await dio.post(
        '/user/verify',
        data: {'email': email, 'code': code},
      );

      final userData = User.fromJson(response.data['user']);
      final token = response.data['access_token'];

      // Refresh token and verified status
      await userData.saveTokenAndVerify(token);

      return AuthResult(
        success: true,
        message: "Email verified successfully!",
        user: userData,
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: e.response?.data['detail'] ?? "Verification failed",
      );
    }
  }

  // 4. RESEND CODE
  Future<AuthResult> resendCode(String email) async {
    try {
      final response = await dio.post(
        '/user/resend-code',
        data: {'email': email},
      );

      return AuthResult(
        success: true,
        message:
            response.data['message'] ?? "Verification code sent successfully!",
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message:
            e.response?.data['detail'] ?? "Failed to resend verification code",
      );
    }
  }
}
