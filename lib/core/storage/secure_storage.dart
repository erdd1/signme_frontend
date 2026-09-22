import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Clés du stockage sécurisé
import 'dart:math';

abstract final class _Keys {
  static const accessToken     = 'access_token';
  static const refreshToken    = 'refresh_token';
  static const user            = 'user_json';
  static const rememberMe      = 'remember_me';
  static const rememberedEmail = 'remembered_email';
  static const deviceId        = 'device_id';
  static const lastCachedUserId = 'last_cached_user_id';
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

  Future<void> saveRememberedEmail(String email) =>
      _storage.write(key: _Keys.rememberedEmail, value: email);

  Future<String?> getRememberedEmail() =>
      _storage.read(key: _Keys.rememberedEmail);

  Future<void> clearRememberedEmail() =>
      _storage.delete(key: _Keys.rememberedEmail);

  /// Identifiant stable de l'appareil (tracking sécurité côté API).
  Future<String> getOrCreateDeviceId() async {
    final existing = await _storage.read(key: _Keys.deviceId);
    if (existing != null && existing.isNotEmpty) return existing;

    final id =
        '${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(999999999)}';
    await _storage.write(key: _Keys.deviceId, value: id);
    return id;
  }

  // ── Dernier utilisateur mis en cache (Isar) ─────────────────────────────────
  // Survit à clearSession()/logout — c'est justement en comparant cette
  // valeur au PROCHAIN utilisateur qui s'authentifie (login, Google, reprise
  // de session) qu'on détecte un changement de compte sur le même appareil
  // et qu'on vide le cache local AVANT d'afficher quoi que ce soit. Filet
  // de sécurité qui fonctionne même si un logout précédent a été sauté
  // (app tuée/crashée sans déconnexion explicite).
  Future<int?> getLastCachedUserId() async {
    final v = await _storage.read(key: _Keys.lastCachedUserId);
    return v == null ? null : int.tryParse(v);
  }

  Future<void> setLastCachedUserId(int userId) =>
      _storage.write(key: _Keys.lastCachedUserId, value: userId.toString());

  // ── Clear ─────────────────────────────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();

  Future<void> clearSession() async {
    await _storage.delete(key: _Keys.accessToken);
    await _storage.delete(key: _Keys.refreshToken);
    await _storage.delete(key: _Keys.user);
  }
}
