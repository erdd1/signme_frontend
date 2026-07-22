import 'dart:async';

import '../../domain/entities/payment_transaction_status.dart';
import '../../domain/repositories/signature_repository.dart';

/// Polling exponentiel du statut paiement (comme les apps Mobile Money).
class PaymentStatusPoller {
  PaymentStatusPoller(this._repository);

  final SignatureRepository _repository;

  static const _maxDuration = Duration(minutes: 3);
  static const _intervalsMs = [2000, 3000, 4000, 5000, 6000, 8000, 10000];

  Timer? _timer;
  DateTime? _startedAt;
  int _tick = 0;
  bool _cancelled = false;

  void cancel() {
    _cancelled = true;
    _timer?.cancel();
    _timer = null;
  }

  Future<PaymentTransactionStatus> pollUntilTerminal({
    required int transactionId,
    void Function(PaymentTransactionStatus status)? onUpdate,
  }) async {
    _cancelled = false;
    _startedAt = DateTime.now();
    _tick = 0;

    PaymentTransactionStatus? last;

    while (!_cancelled) {
      if (DateTime.now().difference(_startedAt!) > _maxDuration) {
        return last ??
            PaymentTransactionStatus(
              status: 'pending',
              progress: 0.5,
              transactionId: transactionId,
            );
      }

      last = await _repository.getTransactionStatus(transactionId);
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

    return last ??
        PaymentTransactionStatus(status: 'pending', progress: 0.0);
  }
}
