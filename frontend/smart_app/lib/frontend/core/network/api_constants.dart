/// Central place for all API URLs.
/// Change [baseUrl] once to affect the entire app.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://172.31.99.85:8000';
  static const String wsUrl = 'ws://172.31.99.85:8000';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String signup = '$baseUrl/api/auth/signup';
  static const String signin = '$baseUrl/api/auth/signin';
  static const String me = '$baseUrl/api/auth/me';

  // ── Users ──────────────────────────────────────────────────────────────────
  static const String users = '$baseUrl/api/users';
  static const String searchUsers = '$baseUrl/api/users/search';

  // ── Conversations ──────────────────────────────────────────────────────────
  static const String conversations = '$baseUrl/api/conversations';
  static String conversationMessages(String id) => '$baseUrl/api/conversations/$id/messages';

  // ── WebSocket ────────────────────────────────────────────────────────────
  static const String wsChat = '$wsUrl/ws/chat';
}
