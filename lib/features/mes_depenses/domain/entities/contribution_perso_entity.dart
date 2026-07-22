/// Contribution personnelle — carte "Mes dépenses" (module accessible à tous).
class ContributionPersoEntity {
  const ContributionPersoEntity({
    required this.uuid,
    this.evenementTitre,
    this.eglise,
    required this.montant,
    required this.frais,
    required this.montantTotal,
    required this.statut,
    this.paymentReference,
    this.note,
    required this.createdAt,
  });

  final String uuid;
  final String? evenementTitre;
  final String? eglise;
  final int montant;
  final int frais;
  final int montantTotal;
  final String statut; // pending | completed | failed
  final String? paymentReference;
  final String? note;
  final DateTime createdAt;

  bool get isCompleted => statut == 'completed';
  bool get isPending => statut == 'pending';
  bool get isFailed => statut == 'failed';

  factory ContributionPersoEntity.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    return ContributionPersoEntity(
      uuid: json['uuid'].toString(),
      evenementTitre: json['evenementTitre']?.toString(),
      eglise: json['eglise']?.toString(),
      montant: asInt(json['montant']),
      frais: asInt(json['frais']),
      montantTotal: asInt(json['montantTotal']),
      statut: (json['statut'] ?? 'pending').toString(),
      paymentReference: json['paymentReference']?.toString(),
      note: json['note']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'evenementTitre': evenementTitre,
        'eglise': eglise,
        'montant': montant,
        'frais': frais,
        'montantTotal': montantTotal,
        'statut': statut,
        'paymentReference': paymentReference,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };
}
