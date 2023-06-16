class DatabaseException implements Exception {
  String? message;

  DatabaseException(this.message);
}

class AuthenticationException implements Exception {
  String? message;

  AuthenticationException(this.message);
}

class StorageException implements Exception {
  String? message;

  StorageException(this.message);
}
class SearchEngineException implements Exception {
  String? message;

  SearchEngineException(this.message);
}
