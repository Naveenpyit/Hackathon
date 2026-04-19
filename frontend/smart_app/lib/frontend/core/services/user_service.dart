import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_constants.dart';
import 'storage_service.dart';

/// Represents a `user_details` row joined with `auth.users`.
///
/// - [id] is the primary key of `user_details`
/// - [userId] is the auth user id (UUID from `auth.users`) — used for
///   identifying the user in chat and comparing against the currently
///   logged-in user.
class AppUser {
  final String id;
  final String userId;
  final String userName;
  final String email;
  final String status;
  final String shiftTime;
  final String? designation;
  final String createdAt;

  const AppUser({
    required this.id,
    required this.userId,
    required this.userName,
    required this.email,
    required this.status,
    required this.shiftTime,
    required this.createdAt,
    this.designation,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // designation can be: { id, name } | String | null
    String? desigName;
    final desig = json['designation'];
    if (desig is Map<String, dynamic>) {
      desigName = desig['name'] as String?;
    } else if (desig is String) {
      desigName = desig;
    }
    return AppUser(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName:
          json['user_name'] as String? ?? json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      shiftTime: json['shift_time'] as String? ?? '',
      designation: desigName,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  bool get isActive => status.toLowerCase() == 'active';
}

class UsersResult {
  final bool success;
  final String message;
  final List<AppUser> users;

  const UsersResult({
    required this.success,
    required this.message,
    this.users = const [],
  });
}

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  /// GET /api/users
  /// Returns list of all users EXCEPT the currently logged-in user.
  Future<UsersResult> getUsers() async {
    try {
      final token = await StorageService.instance.getAccessToken();
      final currentUserId = await StorageService.instance.getUserId();

      final response = await http
          .get(
            Uri.parse(ApiConstants.users),
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.body.isEmpty) {
        return const UsersResult(success: false, message: 'Empty response');
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      final int status = json['status'] as int? ?? 0;
      final String message = json['message'] as String? ?? '';

      if (status == 1 && response.statusCode == 200) {
        final data = json['data'];
        if (data is List) {
          final users = data
              .whereType<Map<String, dynamic>>()
              .map(AppUser.fromJson)
              // exclude users without identity and the currently logged-in user
              .where(
                (u) =>
                    (u.userId.isNotEmpty || u.id.isNotEmpty) &&
                    u.userId != currentUserId &&
                    u.id != currentUserId,
              )
              .toList();
          return UsersResult(success: true, message: message, users: users);
        }
        return const UsersResult(success: true, message: 'No users');
      }

      return UsersResult(success: false, message: message);
    } on http.ClientException catch (e) {
      return UsersResult(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      return const UsersResult(
        success: false,
        message: 'Unable to load users. Please try again.',
      );
    }
  }
}
