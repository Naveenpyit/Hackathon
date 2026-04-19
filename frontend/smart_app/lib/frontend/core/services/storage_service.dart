import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const String _fileName = 'session.json';
  File? _file;

  Future<File> get _sessionFile async {
    if (_file != null) return _file!;
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/$_fileName');
    return _file!;
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String userName,
  }) async {
    try {
      final file = await _sessionFile;
      final data = {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'user_id': userId,
        'user_name': userName,
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final file = await _sessionFile;
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      return data['access_token'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final file = await _sessionFile;
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      return data['refresh_token'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      final file = await _sessionFile;
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      return data['user_id'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserName() async {
    try {
      final file = await _sessionFile;
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      return data['user_name'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    try {
      final file = await _sessionFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }
}