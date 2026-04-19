import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_constants.dart';

// ── Response models ──────────────────────────────────────────────────────────

class SignupResult {
  final bool success;
  final String message;
  final SignupData? data;

  const SignupResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class SignupData {
  final String id;
  final String userId;
  final String email;
  final String userName;
  final String status;
  final String shiftTime;
  final String createdAt;

  const SignupData({
    required this.id,
    required this.userId,
    required this.email,
    required this.userName,
    required this.status,
    required this.shiftTime,
    required this.createdAt,
  });

  factory SignupData.fromJson(Map<String, dynamic> json) {
    return SignupData(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      shiftTime: json['shift_time'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

// ── Service ──────────────────────────────────────────────────────────────────

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// POST /api/auth/signup
  ///
  /// Request body:
  ///   { "email": "...", "password": "...", "user_name": "..." }
  ///
  /// Success response (201):
  ///   { "status": 1, "message": "...", "data": { ... } }
  ///
  /// Error response (400 / 500):
  ///   { "status": 0, "message": "...", "data": null }
  Future<SignupResult> signup({
    required String email,
    required String password,
    required String userName,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.signup),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
              'user_name': userName.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      final int status = json['status'] as int? ?? 0;
      final String message = json['message'] as String? ?? 'Unknown error';

      if (status == 1 && response.statusCode == 201) {
        final data = json['data'] != null
            ? SignupData.fromJson(json['data'] as Map<String, dynamic>)
            : null;
        return SignupResult(success: true, message: message, data: data);
      }

      return SignupResult(success: false, message: message);
    } on http.ClientException catch (e) {
      return SignupResult(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      return SignupResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}
