import 'package:connectivity_plus/connectivity_plus.dart';

/// Service de détection de connectivité réseau.
///
/// Utilisé par les repositories pour décider entre cache local et appel API.
/// Exposé dans Riverpod via [connectivityServiceProvider] (voir connectivity_provider.dart).
class ConnectivityService {
  ConnectivityService() : _connectivity = Connectivity();

  final Connectivity _connectivity;

  // ── Vérification ponctuelle ─────────────────────────────────────────────────

  /// Retourne [true] si l'appareil a accès au réseau, [false] sinon.
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _resultsAreOnline(results);
  }

  // ── Stream réactif ──────────────────────────────────────────────────────────

  /// Émet [true] (en ligne) ou [false] (hors ligne) à chaque changement réseau.
  Stream<bool> get onConnectivityChanged => _connectivity
      .onConnectivityChanged
      .map((results) => _resultsAreOnline(results));

  // ── Privé ──────────────────────────────────────────────────────────────────

  bool _resultsAreOnline(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);
  }
}
