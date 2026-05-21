import 'package:flutter/foundation.dart';

/// Configuration générale de l'application
abstract final class AppConfig {
  // ── Environnement ─────────────────────────────────────────────────────
  static const bool isDebug = kDebugMode;

  // ── App ───────────────────────────────────────────────────────────────
  static const String appName    = 'EEC SIGNCARD';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  static const String supportEmail = 'support@eecsigncard.cm';

  // ── Pagination ────────────────────────────────────────────────────────
  static const int defaultPerPage = 20;
  static const int maxPerPage     = 100;

  // ── Cache ─────────────────────────────────────────────────────────────
  static const Duration cacheDuration = Duration(minutes: 30);

  // ── Campay ────────────────────────────────────────────────────────────
  static const List<String> supportedOperators = [
    'ORANGE MONEY',
    'MTN MOBILE MONEY',
  ];
  static const String currency = 'XAF';

  // ── Signature ─────────────────────────────────────────────────────────
  static const int defaultSignatureAmount = 1000; // XAF par mois

  // ── Sécurité ──────────────────────────────────────────────────────────
  static const int tokenRefreshBufferSeconds = 300; // 5min avant expiry
  static const int maxLoginAttempts = 5;
  static const Duration sessionTimeout = Duration(hours: 8);
}
