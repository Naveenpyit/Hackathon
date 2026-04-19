import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_constants.dart';
import 'storage_service.dart';

class UserData {
  final String id;
  final String userId;
  final String email;
  final String userName;
  final String status;
  final String shiftTime;

  const UserData({
    required this.id,
    required this.userId,
    required this.email,
    required this.userName,
    required this.status,
    required this.shiftTime,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      shiftTime: json['shift_time'] as String? ?? '',
    );
  }
}

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  Future<List<UserData>> getAllUsers() async {
    try {
      final token = await StorageService.instance.getAccessToken();
      final response = await http.get(
        Uri.parse(ApiConstants.users),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['status'] == 1) {
        final data = json['data'] as List<dynamic>? ?? [];
        return data.map((u) => UserData.fromJson(u as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<UserData>> searchUsers(String query) async {
    try {
      final token = await StorageService.instance.getAccessToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.searchUsers}?q=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['status'] == 1) {
        final data = json['data'] as List<dynamic>? ?? [];
        return data.map((u) => UserData.fromJson(u as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> createConversation(String participantId) async {
    try {
      final token = await StorageService.instance.getAccessToken();
      final response = await http.post(
        Uri.parse(ApiConstants.conversations),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'participant_id': participantId}),
      ).timeout(const Duration(seconds: 15));

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['status'] == 1) {
        return json['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getConversations() async {
    try {
      final token = await StorageService.instance.getAccessToken();
      final response = await http.get(
        Uri.parse(ApiConstants.conversations),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['status'] == 1) {
        return json['data'] as List<dynamic>? ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
