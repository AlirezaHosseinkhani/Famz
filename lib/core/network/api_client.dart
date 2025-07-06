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

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final requestHeaders = await _buildHeaders(headers);

      final response = await client.get(uri, headers: requestHeaders);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final requestHeaders = await _buildHeaders(headers);

      final response = await client.post(
        uri,
        // headers: headers,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final requestHeaders = await _buildHeaders(headers);

      final response = await client.put(
        uri,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final requestHeaders = await _buildHeaders(headers);

      final response = await client.patch(
        uri,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final requestHeaders = await _buildHeaders(headers);

      final response = await client.delete(uri, headers: requestHeaders);
      return _handleResponse(response);
    } catch (e) {
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
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
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
      throw _handleError(e);
    }
  }

  Future<Map<String, String>> _buildHeaders(
      Map<String, String>? headers) async {
    final Map<String, String> requestHeaders = {
      'Content-Type': ApiConstants.contentType,
      // 'Accept': ApiConstants.contentType,
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

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw const ServerException('Invalid response format');
      }
    } else {
      throw _mapStatusCodeToException(response.statusCode, response.body);
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

  Exception _mapStatusCodeToException(int statusCode, String body) {
    String message = 'Request failed';

    try {
      final responseBody = json.decode(body) as Map<String, dynamic>;
      message = responseBody['message'] ?? message;
    } catch (e) {
      // If can't parse response body, use default message
    }

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
      case 500:
        return ServerException(message);
      case 502:
        return ServerException('Server temporarily unavailable');
      case 503:
        return ServerException('Service unavailable');
      default:
        return ServerException(message);
    }
  }
}
