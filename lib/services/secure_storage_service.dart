// Author: K K K Ekanayake
// ChronosAI — Secure storage service for sensitive data (API keys)

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing sensitive data like API keys.
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const _apiKeyKey = 'gemini_api_key';

  /// Saves the Gemini API key to secure storage.
  static Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }

  /// Reads the Gemini API key from secure storage.
  /// Returns null if no key is stored.
  static Future<String?> readApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }

  /// Deletes the stored API key.
  static Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }
}
