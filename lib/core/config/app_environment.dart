import 'package:flutter/foundation.dart';

/// Configuration d'environnement injectée au build (évite les secrets en dur).
///
/// Build dev (défaut) :
///   flutter run
///
/// Build prod :
///   flutter build apk --release \
///     --dart-define=API_BASE_URL=https://api.votredomaine.com/api/v1 \
///     --obfuscate --split-debug-info=build/app/outputs/symbols
abstract final class AppEnvironment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.112:8000/api/v1',
  );

  static const bool enableApiLogs = bool.fromEnvironment(
    'ENABLE_API_LOGS',
    defaultValue: false,
  );

  // ── Partage d'événement (Android App Links / iOS Universal Links) ─────
  // Domaine public HTTPS servant la page de partage + les fichiers
  // .well-known (voir routes/web.php côté backend). Doit toujours pointer
  // vers le MÊME domaine que "signmecy.org" déclaré dans AndroidManifest.xml
  // (android:host) et Runner.entitlements (applinks:).
  static const String webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'https://signmecy.org',
  );

  // ── Google Sign-In ───────────────────────────────────────────────────
  // Client ID OAuth "Web" créé dans Google Cloud Console (PAS le client
  // Android/iOS). Utilisé comme `serverClientId` pour que l'ID token
  // généré ait la bonne audience, vérifiable par le backend (GOOGLE_CLIENT_ID
  // dans le .env Laravel doit avoir exactement la même valeur).
  // Un Client ID OAuth n'est pas un secret (il est public dans l'ID token et
  // dans les requêtes Google) : un defaultValue ici est sûr, mais reste
  // surchargeable via --dart-define si besoin (ex: environnement de test).
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '89036303804-acoct8rirtc8ugursmqrerc3p3ni03f5.apps.googleusercontent.com',
  );

  // ── Reverb WebSocket (Offline-First) ─────────────────────────────────
  // En développement :
  //   flutter run (valeurs defaultValue utilisées)
  //
  // En production :
  //   flutter build apk --release \
  //     --dart-define=API_BASE_URL=https://api.votredomaine.com/api/v1 \
  //     --dart-define=REVERB_APP_KEY=votre_clé_publique \
  //     --dart-define=REVERB_HOST=api.votredomaine.com \
  //     --dart-define=REVERB_PORT=443 \
  //     --dart-define=REVERB_USE_TLS=true

  static const String reverbAppKey = String.fromEnvironment(
    'REVERB_APP_KEY',
    defaultValue: 'signme_local_key',
  );

  static const String reverbHost = String.fromEnvironment(
    'REVERB_HOST',
    defaultValue: '192.168.1.112',
  );

  static const int reverbPort = int.fromEnvironment(
    'REVERB_PORT',
    defaultValue: 8080,
  );

  /// true en production (WSS/HTTPS), false en développement local (WS/HTTP).
  static const bool reverbUseTLS = bool.fromEnvironment(
    'REVERB_USE_TLS',
    defaultValue: false,
  );

  static bool get isProduction => kReleaseMode;

  static bool get allowDebugFeatures => kDebugMode;

  /// Garde-fou publication : un build --release qui pointerait encore vers
  /// [apiBaseUrl]'s valeur par défaut (IP locale, HTTP non chiffré) — parce
  /// que le flag --dart-define=API_BASE_URL a été oublié — échoue bruyamment
  /// au lancement plutôt que d'expédier silencieusement du trafic en clair
  /// vers une IP de développeur. À appeler tout en haut de `main()`.
  static void assertValidForRelease() {
    if (!kReleaseMode) return;
    if (!apiBaseUrl.startsWith('https://')) {
      throw StateError(
        'Build release avec API_BASE_URL non-HTTPS ($apiBaseUrl). '
        'Relancez avec --dart-define=API_BASE_URL=https://votre-domaine/api/v1',
      );
    }
  }
}
