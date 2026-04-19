/// Central place for all API URLs.
/// Change [baseUrl] once to affect the entire app.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://172.31.99.85:8000';
  static const String wsUrl = 'ws://172.31.99.85:8000';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String signup = '$baseUrl/api/auth/signup';
  static const String signin = '$baseUrl/api/auth/signin';

  // ── Users ────────────────────────────────────────────────────────────────
  static const String users = '$baseUrl/api/users';

  // ── WebSocket ────────────────────────────────────────────────────────────
  static const String wsChat = '$wsUrl/ws/chat';
}
