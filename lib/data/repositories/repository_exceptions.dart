class EntityNotFoundException implements Exception {
  final String message;
  EntityNotFoundException(this.message);

  @override
  String toString() => 'EntityNotFoundException: $message';
}

class DuplicateEntityException implements Exception {
  final String message;
  DuplicateEntityException(this.message);

  @override
  String toString() => 'DuplicateEntityException: $message';
}

class ProtectedEntityException implements Exception {
  final String message;
  ProtectedEntityException(this.message);

  @override
  String toString() => 'ProtectedEntityException: $message';
}

class EntityInUseException implements Exception {
  final String message;
  EntityInUseException(this.message);

  @override
  String toString() => 'EntityInUseException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
