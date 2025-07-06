import 'dart:io';

import 'package:http/http.dart' as http;

import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure handleException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message, code: exception.code);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message, code: exception.code);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message, code: exception.code);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message, code: exception.code);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message, code: exception.code);
    } else if (exception is PermissionException) {
      return PermissionFailure(exception.message, code: exception.code);
    } else if (exception is FileException) {
      return FileFailure(exception.message, code: exception.code);
    } else {
      return ServerFailure('An unexpected error occurred');
    }
  }

  static Exception handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return const ValidationException('Bad request');
      case 401:
        return const AuthException('Unauthorized');
      case 403:
        return const AuthException('Forbidden');
      case 404:
        return const ServerException('Not found');
      case 422:
        return const ValidationException('Validation error');
      case 500:
        return const ServerException('Internal server error');
      case 502:
        return const ServerException('Bad gateway');
      case 503:
        return const ServerException('Service unavailable');
      default:
        return ServerException('Server error: ${response.statusCode}');
    }
  }

  static Exception handleSocketException(SocketException exception) {
    return NetworkException(
      'Network error: ${exception.message}',
      originalError: exception,
    );
  }

  static Exception handleHttpException(HttpException exception) {
    return NetworkException(
      'HTTP error: ${exception.message}',
      originalError: exception,
    );
  }

  static Exception handleFormatException(FormatException exception) {
    return ServerException(
      'Data format error: ${exception.message}',
      originalError: exception,
    );
  }

  static String getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Please check your internet connection';
      case AuthFailure:
        return 'Authentication failed. Please login again';
      case ValidationFailure:
        return 'Please check your input';
      case PermissionFailure:
        return 'Permission required to continue';
      case FileFailure:
        return 'File operation failed';
      case CacheFailure:
        return 'Data loading failed';
      case ServerFailure:
      default:
        return 'Something went wrong. Please try again';
    }
  }
}
