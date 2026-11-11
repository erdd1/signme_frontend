/// Statut d'une transaction de signature à distance (polling mobile).
class PaymentTransactionStatus {
  const PaymentTransactionStatus({
    required this.status,
    required this.progress,
    this.transactionId,
    this.paymentReference,
    this.totalAmount,
    this.isTerminal = false,
    this.pollIntervalMs = 3000,
    this.checkoutUrl,
  });

  final String status;
  final double progress;
  final int? transactionId;
  final String? paymentReference;
  final num? totalAmount;
  final bool isTerminal;
  final int pollIntervalMs;

  /// Page de paiement hébergée (carte), tant que le paiement est en attente.
  final String? checkoutUrl;

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending' || status == 'processing';

  factory PaymentTransactionStatus.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionStatus(
      status: json['status']?.toString() ?? 'pending',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.25,
      transactionId: json['transaction_id'] as int? ??
          int.tryParse(json['transaction_id']?.toString() ?? ''),
      paymentReference: json['payment_reference']?.toString(),
      totalAmount: json['total_amount'] as num?,
      isTerminal: json['is_terminal'] == true,
      pollIntervalMs: json['poll_interval_ms'] as int? ?? 3000,
      checkoutUrl: json['checkout_url']?.toString(),
    );
  }
}

/// Résultat de l'initiation paiement à distance.
class DistancePaymentInitResult {
  const DistancePaymentInitResult({
    required this.transactionId,
    required this.paymentReference,
    required this.totalAmount,
    this.message,
    this.checkoutUrl,
  });

  final int transactionId;
  final String paymentReference;
  final num totalAmount;
  final String? message;

  /// Page de paiement hébergée — présente uniquement pour un paiement par carte.
  final String? checkoutUrl;

  factory DistancePaymentInitResult.fromJson(Map<String, dynamic> json) {
    return DistancePaymentInitResult(
      transactionId: json['transaction_id'] as int? ??
          int.parse(json['transaction_id'].toString()),
      paymentReference: json['payment_reference']?.toString() ?? '',
      totalAmount: json['total_amount'] as num? ?? 0,
      message: json['message']?.toString(),
      checkoutUrl: json['checkout_url']?.toString(),
    );
  }
}
