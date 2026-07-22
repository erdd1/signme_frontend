import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';

// ── Provider du service (singleton) ────────────────────────────────────────

/// Service de connectivité — injecté dans les datasources et providers.
final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);

// ── StreamProvider réactif ──────────────────────────────────────────────────

/// Stream Riverpod — émet [true] (en ligne) / [false] (hors ligne).
///
/// Utilisé dans les widgets pour afficher le bannière "Mode hors ligne"
/// et dans le [WsClient] pour déclencher la reconnexion.
///
/// Exemple d'utilisation :
/// ```dart
/// final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
/// ```
final connectivityProvider = StreamProvider<bool>(
  (ref) => ref.watch(connectivityServiceProvider).onConnectivityChanged,
);
