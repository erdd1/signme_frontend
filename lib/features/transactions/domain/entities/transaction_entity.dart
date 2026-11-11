/// Type d'une transaction financière.
enum TransactionType { contribution, don, signature }

/// Statut d'une transaction.
enum TransactionStatus { completed, pending, failed }

/// Opération financière de l'utilisateur, quelle qu'en soit l'origine :
/// contribution à un événement, don, signature (Sainte-Cène)… — payée par
/// Mobile Money, carte bancaire ou espèces.
class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.type,
    required this.motif,
    required this.details,
    required this.montant,
    required this.frais,
    required this.montantTotal,
    required this.status,
    required this.paymentMethod,
    required this.paymentLabel,
    required this.createdAt,
    this.eglise,
    this.paymentNumber,
    this.cardBrand,
    this.cardLast4,
    this.reference,
    this.receivedBy,
  });

  final String id;
  final TransactionType type;

  /// Objet de la transaction (« Don à l'église », « Contribution — … »).
  final String motif;

  /// Précisions (ex. les mois d'une signature).
  final List<String> details;
  final String? eglise;
  final int montant;
  final int frais;
  final int montantTotal;
  final TransactionStatus status;

  /// mobile_money | card | cash
  final String paymentMethod;
  final String paymentLabel;
  final String? paymentNumber;
  final String? cardBrand;
  final String? cardLast4;
  final String? reference;
  final String? receivedBy;
  final DateTime createdAt;

  bool get isCard => paymentMethod == 'card';
  bool get isCash => paymentMethod == 'cash';

  String get typeLabel => switch (type) {
        TransactionType.contribution => 'Contribution à un événement',
        TransactionType.don => 'Don',
        TransactionType.signature => 'Signature (Sainte-Cène)',
      };

  /// Compte débité : numéro Mobile Money, carte masquée ou « Espèces ».
  String get account {
    if (isCash) return 'Espèces';
    if (isCard) {
      return cardLast4 == null ? 'Carte bancaire' : '${cardBrand ?? 'Carte'} •••• $cardLast4';
    }
    return paymentNumber == null ? paymentLabel : formatCameroonPhone(paymentNumber!);
  }

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    return TransactionEntity(
      id: json['id']?.toString() ?? '',
      type: switch (json['type']) {
        'don' => TransactionType.don,
        'signature' => TransactionType.signature,
        _ => TransactionType.contribution,
      },
      motif: json['motif']?.toString() ?? '',
      details: (json['details'] as List? ?? const []).map((e) => e.toString()).toList(),
      eglise: json['eglise']?.toString(),
      montant: asInt(json['montant']),
      frais: asInt(json['frais']),
      montantTotal: asInt(json['montantTotal']),
      status: switch (json['statut']) {
        'completed' => TransactionStatus.completed,
        'failed' => TransactionStatus.failed,
        _ => TransactionStatus.pending,
      },
      paymentMethod: json['paymentMethod']?.toString() ?? 'mobile_money',
      paymentLabel: json['paymentLabel']?.toString() ?? 'Mobile Money',
      paymentNumber: json['paymentNumber']?.toString(),
      cardBrand: json['cardBrand']?.toString(),
      cardLast4: json['cardLast4']?.toString(),
      reference: json['reference']?.toString(),
      receivedBy: json['receivedBy']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// « 699803165 » → « +237 6 99 80 31 65 ». Tout autre format est renvoyé tel quel.
String formatCameroonPhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('237')) digits = digits.substring(3);
  if (digits.length != 9) return raw;

  return '+237 ${digits[0]} ${digits.substring(1, 3)} ${digits.substring(3, 5)} '
      '${digits.substring(5, 7)} ${digits.substring(7, 9)}';
}

/// Une page de résultats de l'historique.
class TransactionsPage {
  const TransactionsPage({required this.items, required this.currentPage, required this.lastPage});

  final List<TransactionEntity> items;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}
