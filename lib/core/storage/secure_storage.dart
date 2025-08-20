import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  const SecureStorage(this._storage);

  // Token management
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: StorageKeys.accessToken);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  // Clear both tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  // Device ID
  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: StorageKeys.deviceId, value: deviceId);
  }

  Future<String?> getDeviceId() async {
    return await _storage.read(key: StorageKeys.deviceId);
  }

  Future<void> deleteDeviceId() async {
    await _storage.delete(key: StorageKeys.deviceId);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
