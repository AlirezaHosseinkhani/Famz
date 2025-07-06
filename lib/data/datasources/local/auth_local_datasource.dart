import '../../../core/storage/secure_storage.dart';
import '../../../core/storage/shared_preferences_helper.dart';
import '../../models/auth/token_model.dart';
import '../../models/auth/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(TokenModel tokens);

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> clearTokens();

  Future<void> saveUser(UserModel user);

  Future<UserModel?> getCachedUser();

  Future<void> clearUser();

  Future<bool> isLoggedIn();

  Future<void> setLoggedIn(bool isLoggedIn);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage secureStorage;
  final SharedPreferencesHelper sharedPreferencesHelper;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferencesHelper,
  });

  @override
  Future<void> saveTokens(TokenModel tokens) async {
    await secureStorage.saveAccessToken(tokens.access);
    await secureStorage.saveRefreshToken(tokens.refresh);
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.getRefreshToken();
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.clearTokens();
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await sharedPreferencesHelper.saveUserData(user.toJson());
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userData = sharedPreferencesHelper.getUserData();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferencesHelper.clearUserData();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await secureStorage.isLoggedIn();
  }

  @override
  Future<void> setLoggedIn(bool isLoggedIn) async {
    await sharedPreferencesHelper.setLoggedIn(isLoggedIn);
  }
}
