import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/auth/login_request_model.dart';
import '../../models/auth/login_response_model.dart';
import '../../models/auth/register_request_model.dart';
import '../../models/auth/token_model.dart';
import '../../models/auth/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> sendVerificationCode(LoginRequestModel request);

  Future<TokenModel> verifyOtpAndLogin(String phoneNumber, String otpCode);

  Future<TokenModel> login(String phoneNumber, String password);

  Future<TokenModel> register(RegisterRequestModel request);

  Future<void> logout();

  Future<TokenModel> refreshToken(String refreshToken);

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<LoginResponseModel> sendVerificationCode(
      LoginRequestModel request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.loginEndpoint,
        body: request.toJson(),
      );
      return LoginResponseModel.fromJson(response);
    } catch (e) {
      _handleException(e, 'Failed to send verification code');
      rethrow;
    }
  }

  @override
  Future<TokenModel> verifyOtpAndLogin(
      String phoneNumber, String otpCode) async {
    try {
      final response = await apiClient.post(
        ApiConstants.verifyOtpEndpoint,
        body: {
          'phone_number': phoneNumber,
          'otp_code': otpCode,
        },
      );
      return TokenModel.fromJson(response);
    } catch (e) {
      _handleException(e, 'OTP verification failed');
      rethrow;
    }
  }

  @override
  Future<TokenModel> login(String phoneNumber, String password) async {
    try {
      final response = await apiClient.post(
        ApiConstants.loginEndpoint,
        body: {
          'email': phoneNumber,
          'password': password,
        },
      );
      return TokenModel.fromJson(response);
    } catch (e) {
      _handleException(e, 'Login failed');
      rethrow;
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
      _handleException(e, 'Registration failed');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(
        ApiConstants.logoutEndpoint,
      );
    } catch (e) {
      _handleException(e, 'Logout failed');
      rethrow;
    }
  }

  @override
  Future<TokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post(
        ApiConstants.refreshTokenEndpoint,
        body: {
          'refresh': refreshToken,
        },
      );
      return TokenModel.fromJson(response);
    } catch (e) {
      _handleException(e, 'Token refresh failed');
      rethrow;
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get(
        ApiConstants.profileEndpoint,
      );
      return UserModel.fromJson(response);
    } catch (e) {
      _handleException(e, 'Failed to get current user');
      rethrow;
    }
  }

  void _handleException(dynamic error, String defaultMessage) {
    if (error is AuthException ||
        error is NetworkException ||
        error is ServerException ||
        error is ValidationException) {
      return;
    }
    throw ServerException(defaultMessage);
  }
}
