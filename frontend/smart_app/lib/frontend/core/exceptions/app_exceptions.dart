class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  ApiException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({required this.message, this.code});

  @override
  String toString() => message;
}
