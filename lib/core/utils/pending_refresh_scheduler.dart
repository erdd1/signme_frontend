import 'dart:async';

/// Poll léger et auto-arrêté, à brancher dans un `StateNotifier` d'historique
/// de paiement : reprogrammé après chaque rafraîchissement tant qu'un item
/// "en cours de traitement" est présent dans le dernier état connu, s'arrête
/// dès qu'il n'y en a plus.
///
/// Donne un effet "temps réel" (l'utilisateur voit sa signature/contribution
/// passer de "en cours de traitement" à "payé"/"paiement échoué" sans tirer
/// pour rafraîchir) en s'appuyant sur le mécanisme de refresh déjà existant
/// plutôt que sur un canal WebSocket dédié par paiement — le webhook NotchPay
/// met déjà à jour le statut côté backend en quelques secondes ; il suffit
/// de revenir le lire, comme le fait déjà [PaymentStatusPoller] pour l'écran
/// de confirmation d'un paiement individuel.
///
/// Abandon au bout de [maxAttempts] (par défaut ~3 min, même durée que
/// [PaymentStatusPoller]) : un paiement qui reste bloqué au-delà relève du
/// rafraîchissement manuel (pull-to-refresh, ou ré-ouverture de l'onglet —
/// déjà déclenché ailleurs dans l'app), pas d'un polling indéfini qui
/// viderait la batterie pour rien.
class PendingRefreshScheduler {
  PendingRefreshScheduler({
    required Future<void> Function() refresh,
    this.interval = const Duration(seconds: 6),
    this.maxAttempts = 30,
  }) : _refresh = refresh;

  final Future<void> Function() _refresh;
  final Duration interval;
  final int maxAttempts;

  Timer? _timer;
  int _attempts = 0;

  /// À appeler après chaque mise à jour d'état, avec `true` si l'état
  /// contient au moins un item en attente de résolution.
  void scheduleIfNeeded(bool hasPending) {
    if (!hasPending) {
      _stop();
      return;
    }
    if (_timer != null || _attempts >= maxAttempts) return;

    _timer = Timer(interval, () async {
      _timer = null;
      _attempts++;
      await _refresh();
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    // Un futur nouveau paiement pending doit repartir avec un budget complet.
    _attempts = 0;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
