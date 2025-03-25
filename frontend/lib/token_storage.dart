import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // Create an instance of FlutterSecureStorage
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Save token securely
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'admin_token', value: token);
  }

  // Get token securely
  Future<String?> getToken() async {
    return await _storage.read(key: 'admin_token');
  }

  // Delete token securely (for logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: 'admin_token');
  }
}
