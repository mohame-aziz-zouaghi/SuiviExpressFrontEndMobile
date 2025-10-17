import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final _storage = FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';
  static const _roleKey = 'auth_role';
  static const _userIdKey = 'auth_userId';

  // Save
  static Future<void> saveAuthData(String token, String username, String role, String userId) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _userIdKey, value: userId);
  }

  // Read
  static Future<String?> getToken() async => await _storage.read(key: _tokenKey);
  static Future<String?> getUsername() async => await _storage.read(key: _usernameKey);
  static Future<String?> getRole() async => await _storage.read(key: _roleKey);
  static Future<String?> getuserId() async => await _storage.read(key: _userIdKey);

  // Delete (logout)
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
