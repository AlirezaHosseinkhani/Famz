// lib/data/datasources/remote/auth_remote_datasource.dart
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
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
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CheckExistenceResponseModel> checkExistence(
      CheckExistenceRequestModel request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.checkExistenceEndpoint,
        body: request.toJson(),
      );
      return CheckExistenceResponseModel.fromJson(response);
    } catch (e) {
      throw ServerException('Check existence failed');
    }
  }

  @override
  Future<TokenModel> login(LoginRequestModel request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.loginEndpoint,
        body: request.toJson(),
      );
      return TokenModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TokenModel> register(RegisterRequestModel request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.registerEndpoint,
        body: request.toJson(),
      );
      return TokenModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiConstants.logoutEndpoint);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post(
        ApiConstants.refreshTokenEndpoint,
        body: {'refresh': refreshToken},
      );
      return TokenModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get(ApiConstants.profileEndpoint);
      return UserModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
