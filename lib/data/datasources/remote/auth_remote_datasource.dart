// lib/data/datasources/remote/auth_remote_datasource.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/auth/check_existence_request_model.dart';
import '../../models/auth/check_existence_response_model.dart';
import '../../models/auth/login_request_model.dart';
import '../../models/auth/register_request_model.dart';
import '../../models/auth/token_model.dart';
import '../../models/auth/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<CheckExistenceResponseModel> checkExistence(
      CheckExistenceRequestModel request);

  Future<TokenModel> login(LoginRequestModel request);

  Future<TokenModel> register(RegisterRequestModel request);

  Future<void> logout();

  Future<TokenModel> refreshToken(String refreshToken);

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<CheckExistenceResponseModel> checkExistence(
      CheckExistenceRequestModel request) async {
    try {
      final response = await client.post(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.checkExistenceEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return CheckExistenceResponseModel.fromJson(jsonResponse);
      } else {
        _handleErrorResponse(response);
        throw ServerException('Check existence failed');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw NetworkException('Network error occurred');
    }
  }

  @override
  Future<TokenModel> login(LoginRequestModel request) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return TokenModel.fromJson(jsonResponse);
      } else {
        _handleErrorResponse(response);
        throw ServerException('Login failed');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw NetworkException('Network error occurred');
    }
  }

  @override
  Future<TokenModel> register(RegisterRequestModel request) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return TokenModel.fromJson(jsonResponse);
      } else {
        _handleErrorResponse(response);
        throw ServerException('Registration failed');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw NetworkException('Network error occurred');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logoutEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        _handleErrorResponse(response);
        throw ServerException('Logout failed');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw NetworkException('Network error occurred');
    }
  }

  @override
  Future<TokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await client.post(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.refreshTokenEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return TokenModel.fromJson(jsonResponse);
      } else {
        _handleErrorResponse(response);
        throw ServerException('Token refresh failed');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw NetworkException('Network error occurred');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return UserModel.fromJson(jsonResponse);
      } else {
        _handleErrorResponse(response);
        throw ServerException('Failed to get current user');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw NetworkException('Network error occurred');
    }
  }

  void _handleErrorResponse(http.Response response) {
    final statusCode = response.statusCode;
    String message = 'An error occurred';

    try {
      final jsonResponse = jsonDecode(response.body);
      message = jsonResponse['message'] ?? jsonResponse['error'] ?? message;
    } catch (e) {
      // If JSON parsing fails, use default message
    }

    if (statusCode >= 400 && statusCode < 500) {
      throw AuthException(message);
    } else if (statusCode >= 500) {
      throw ServerException(message);
    } else {
      throw ServerException(message);
    }
  }
}
