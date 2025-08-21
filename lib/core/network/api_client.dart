import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  final http.Client client;
  final SecureStorage secureStorage;

  ApiClient({
    required this.client,
    required this.secureStorage,
  });

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    bool expectList = false,
  }) async {
    try {
      final baseUrl = await ApiConstants.baseUrl;
      final uri = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = await _buildHeaders(headers);

      final response = await client.get(uri, headers: requestHeaders);
      return _handleResponse(response, expectList: expectList);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final baseUrl = await ApiConstants.baseUrl;
      final uri = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = await _buildHeaders(headers);

      final response = await client.post(
        uri,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final baseUrl = await ApiConstants.baseUrl;
      final uri = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = await _buildHeaders(headers);

      final response = await client.put(
        uri,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final baseUrl = await ApiConstants.baseUrl;
      final uri = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = await _buildHeaders(headers);

      final response = await client.patch(
        uri,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final baseUrl = await ApiConstants.baseUrl;
      final uri = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = await _buildHeaders(headers);

      final response = await client.delete(uri, headers: requestHeaders);
      if (response.statusCode == 204) {
        return {};
      }
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> multipartRequest(
    String method,
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, String>? headers,
  }) async {
    try {
      final baseUrl = await ApiConstants.baseUrl;
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest(method, uri);

      // Add headers
      final requestHeaders = await _buildHeaders(headers);
      request.headers.addAll(requestHeaders);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          final file = await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
          );
          request.files.add(file);
        }
      }

      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw _handleError(e);
    }
  }

  Future<Map<String, String>> _buildHeaders(
      Map<String, String>? headers) async {
    final Map<String, String> requestHeaders = {
      'Content-Type': ApiConstants.contentType,
    };

    // Add custom headers
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    // Add authorization header if token exists
    final token = await secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      requestHeaders[ApiConstants.authorization] =
          '${ApiConstants.bearer} $token';
    }

    return requestHeaders;
  }

  dynamic _handleResponse(http.Response response, {bool expectList = false}) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return expectList ? [] : {};
      }

      try {
        final decoded = json.decode(response.body);

        if (expectList && decoded is List) {
          return decoded;
        } else if (!expectList && decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          throw const ServerException('Unexpected response format');
        }
      } catch (e) {
        throw const ServerException('Invalid response format');
      }
    } else {
      // Handle error response with server message
      throw _handleErrorResponse(response);
    }
  }

  Exception _handleErrorResponse(http.Response response) {
    final statusCode = response.statusCode;
    String message = 'An error occurred';

    // Try to extract error message from response body
    try {
      final jsonResponse = jsonDecode(response.body);
      message = jsonResponse['detail'] ?? jsonResponse['message'] ?? message;
    } catch (e) {
      // If JSON parsing fails, use default message or raw body if it's short
      if (response.body.isNotEmpty && response.body.length < 200) {
        message = response.body;
      }
    }

    // Map status codes to appropriate exceptions
    switch (statusCode) {
      case 400:
        return ValidationException(message);
      case 401:
        return AuthException(message);
      case 403:
        return AuthException(message);
      case 404:
        return ServerException(message);
      case 422:
        return ValidationException(message);
      case 429:
        return ServerException('Too many requests. Please try again later.');
      case 500:
        return ServerException(message);
      case 502:
        return ServerException('Server temporarily unavailable');
      case 503:
        return ServerException('Service unavailable');
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return ValidationException(message);
        } else if (statusCode >= 500) {
          return ServerException(message);
        } else {
          return ServerException(message);
        }
    }
  }

  Exception _handleError(dynamic error) {
    if (error is SocketException) {
      return const NetworkException('No internet connection');
    } else if (error is HttpException) {
      return NetworkException('Network error: ${error.message}');
    } else if (error is FormatException) {
      return const ServerException('Invalid response format');
    } else if (error is AppException) {
      return error;
    } else {
      return ServerException('Unexpected error: ${error.toString()}');
    }
  }
}
