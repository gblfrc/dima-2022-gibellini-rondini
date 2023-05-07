class DatabaseException implements Exception {
  String? message;

  DatabaseException(this.message);
}

class AuthenticationException implements Exception {
  String? message;

  AuthenticationException(this.message);
}
