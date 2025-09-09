abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

// class ServerException extends AppException {
//   const ServerException(super.message);
// }

class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class CacheException extends AppException {
  const CacheException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class PermissionException extends AppException {
  const PermissionException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class FileException extends AppException {
  const FileException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class BadRequestException extends AppException {
  const BadRequestException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class NotFoundException extends AppException {
  const NotFoundException(
    super.message, {
    super.code,
    super.originalError,
  });
}
