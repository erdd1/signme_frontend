import 'dart:async';

import '../../domain/entities/contribution_entity.dart';
import '../../domain/repositories/contribution_repository.dart';

/// Polling exponentiel du statut d'une contribution. Miroir de
/// PaymentStatusPoller (module signature) — dupliqué volontairement pour
/// garder les deux modules indépendants plutôt que de coupler leurs
/// implémentations de paiement.
class ContributionStatusPoller {
  /// [maxDuration] : 3 min pour un paiement Mobile Money (simple PUSH à
  /// valider) ; plus long pour une carte, dont la saisie et l'éventuelle
  /// authentification de la banque prennent du temps.
  ContributionStatusPoller(this._repository, {this.maxDuration = const Duration(minutes: 3)});

  final ContributionRepository _repository;
  final Duration maxDuration;

  static const _intervalsMs = [2000, 3000, 4000, 5000, 6000, 8000, 10000];

  DateTime? _startedAt;
  int _tick = 0;
  bool _cancelled = false;

  void cancel() => _cancelled = true;

  Future<ContributionEntity> pollUntilTerminal({
    required String contributionUuid,
    void Function(ContributionEntity status)? onUpdate,
  }) async {
    _cancelled = false;
    _startedAt = DateTime.now();
    _tick = 0;

    ContributionEntity? last;

    while (!_cancelled) {
      if (DateTime.now().difference(_startedAt!) > maxDuration) {
        return last ?? await _repository.getStatus(contributionUuid);
      }

      last = await _repository.getStatus(contributionUuid);
      onUpdate?.call(last);

      if (last.isTerminal || last.isCompleted || last.isFailed) {
        return last;
      }

      final delayMs = last.pollIntervalMs > 0
          ? last.pollIntervalMs
          : _intervalsMs[_tick.clamp(0, _intervalsMs.length - 1)];

      _tick++;
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }

    return last ?? await _repository.getStatus(contributionUuid);
  }
}
