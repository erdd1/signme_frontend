import 'dart:async';

import '../../domain/entities/contribution_entity.dart';
import '../../domain/repositories/contribution_repository.dart';

/// Polling exponentiel du statut d'une contribution. Miroir de
/// PaymentStatusPoller (module signature) — dupliqué volontairement pour
/// garder les deux modules indépendants plutôt que de coupler leurs
/// implémentations de paiement.
class ContributionStatusPoller {
  ContributionStatusPoller(this._repository);

  final ContributionRepository _repository;

  static const _maxDuration = Duration(minutes: 3);
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
      if (DateTime.now().difference(_startedAt!) > _maxDuration) {
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
