/// Contribution à un événement — vue trésorerie (pasteur/secrétaire/trésorier)
/// ou vue contributeur (soi-même). Les champs sensibles (note, opérateur,
/// numéro, référence) sont `null` quand le backend a masqué l'accès.
class ContributionEntity {
  const ContributionEntity({
    required this.uuid,
    required this.montant,
    required this.frais,
    required this.montantTotal,
    required this.statut,
    this.note,
    this.paymentMethod,
    this.paymentOperator,
    this.paymentNumber,
    this.paymentReference,
    this.authorizationUrl,
    this.contributeurId,
    this.contributeurNom,
    this.contributeurGroupeNom,
    this.evenementTitre,
    required this.createdAt,
    this.isTerminal = false,
    this.pollIntervalMs = 3000,
  });

  final String uuid;
  final int montant;
  final int frais;
  final int montantTotal;
  final String statut; // pending | completed | failed
  final String? note;
  final String? paymentMethod; // mobile_money | card
  final String? paymentOperator;
  final String? paymentNumber;
  final String? paymentReference;
  final String? authorizationUrl;
  final int? contributeurId;
  final String? contributeurNom;
  final String? contributeurGroupeNom;
  final String? evenementTitre;
  final DateTime createdAt;
  final bool isTerminal;
  final int pollIntervalMs;

  bool get isPending => statut == 'pending';
  bool get isCompleted => statut == 'completed';
  bool get isFailed => statut == 'failed';

  /// Progression pour la barre de paiement (même mapping que
  /// PaymentStatusCache::payloadFromModel côté backend).
  double get progress => switch (statut) {
        'completed' => 1.0,
        'failed' => 0.0,
        _ => 0.25,
      };
}
