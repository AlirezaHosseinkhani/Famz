import '../../../core/constants/api_constants.dart';
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

  Future<UserModel> register(RegisterRequestModel request);

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
    final response = await apiClient.post(
      ApiConstants.loginEndpoint,
      body: request.toJson(),
    );
    return LoginResponseModel.fromJson(response);
  }

  @override
  Future<TokenModel> verifyOtpAndLogin(
      String phoneNumber, String otpCode) async {
    final response = await apiClient.post(
      ApiConstants.verifyOtpEndpoint,
      body: {
        'phone_number': phoneNumber,
        'otp_code': otpCode,
      },
    );
    return TokenModel.fromJson(response);
  }

  @override
  Future<TokenModel> login(String phoneNumber, String otpCode) async {
    final response = await apiClient.post(
      ApiConstants.loginEndpoint,
      body: {
        'email': phoneNumber,
        'password': otpCode,
      },
    );
    return TokenModel.fromJson(response);
  }

  @override
  Future<UserModel> register(RegisterRequestModel request) async {
    final response = await apiClient.post(
      ApiConstants.registerEndpoint,
      body: request.toJson(),
    );
    return UserModel.fromJson(response['user']);
  }

  @override
  Future<void> logout() async {
    await apiClient.post(ApiConstants.logoutEndpoint);
  }

  @override
  Future<TokenModel> refreshToken(String refreshToken) async {
    final response = await apiClient.post(
      ApiConstants.refreshTokenEndpoint,
      body: {
        'refresh_token': refreshToken,
      },
    );
    return TokenModel.fromJson(response);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get(ApiConstants.profileEndpoint);
    return UserModel.fromJson(response);
  }
}
