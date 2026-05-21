import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Clés du stockage sécurisé
abstract final class _Keys {
  static const accessToken  = 'access_token';
  static const refreshToken = 'refresh_token';
  static const user         = 'user_json';
  static const rememberMe   = 'remember_me';
}

/// Service de stockage sécurisé — Keychain (iOS) / Keystore (Android)
class SecureStorage {
  SecureStorage()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  final FlutterSecureStorage _storage;

  // ── Access Token ──────────────────────────────────────────────────────────
  Future<void>    saveAccessToken(String token) =>
      _storage.write(key: _Keys.accessToken, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: _Keys.accessToken);

  // ── Refresh Token ─────────────────────────────────────────────────────────
  Future<void>    saveRefreshToken(String token) =>
      _storage.write(key: _Keys.refreshToken, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: _Keys.refreshToken);

  // ── User JSON ─────────────────────────────────────────────────────────────
  Future<void>    saveUser(String userJson) =>
      _storage.write(key: _Keys.user, value: userJson);

  Future<String?> getUser() =>
      _storage.read(key: _Keys.user);

  // ── Remember Me ───────────────────────────────────────────────────────────
  Future<void> saveRememberMe(bool value) =>
      _storage.write(key: _Keys.rememberMe, value: value.toString());

  Future<bool> getRememberMe() async {
    final v = await _storage.read(key: _Keys.rememberMe);
    return v == 'true';
  }

  // ── Clear ─────────────────────────────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();

  Future<void> clearSession() async {
    await _storage.delete(key: _Keys.accessToken);
    await _storage.delete(key: _Keys.refreshToken);
    await _storage.delete(key: _Keys.user);
  }
}
