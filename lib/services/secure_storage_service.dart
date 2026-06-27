// Author: K K K Ekanayake
// ChronosAI — Secure storage service for sensitive data (API keys)

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _apiKeyKey = 'gemini_api_key';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Save the Gemini API key securely (Android Keystore backed)
  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }

  /// Retrieve the stored API key. Returns null if not set.
  Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }

  /// Check if an API key has been stored.
  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Delete the stored API key.
  Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }

  /// Validate that the key looks like a valid Gemini API key format.
  static bool isValidApiKeyFormat(String key) {
    return key.startsWith('AIza') && key.length >= 30;
  }
}
