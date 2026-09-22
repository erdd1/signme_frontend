class RetraitEntity {
  const RetraitEntity({
    required this.uuid,
    required this.montantDemande,
    required this.frais,
    required this.montantNet,
    required this.statut,
    required this.reference,
    this.motifEchec,
    this.soldeApres,
    this.beneficiaireOperator,
    this.beneficiaireNumeroMasque,
    required this.auteurNom,
    this.completedAt,
    required this.createdAt,
  });

  final String uuid;
  final int montantDemande;
  final int frais;
  final int montantNet;
  final String statut; // pending | processing | completed | failed
  final String reference;
  final String? motifEchec;
  final int? soldeApres;
  final String? beneficiaireOperator;
  final String? beneficiaireNumeroMasque;
  final String auteurNom;
  final String? completedAt;
  final String createdAt;

  bool get isPending => statut == 'pending';
  bool get isProcessing => statut == 'processing';
  bool get isCompleted => statut == 'completed';
  bool get isFailed => statut == 'failed';
  bool get isFinal => isCompleted || isFailed;

  String get statutLabel => switch (statut) {
        'pending' => 'En attente',
        'processing' => 'En cours',
        'completed' => 'Réussi',
        'failed' => 'Échoué',
        _ => statut,
      };

  factory RetraitEntity.fromJson(Map<String, dynamic> json) {
    final beneficiaire = json['beneficiaire'] as Map<String, dynamic>?;
    final auteur = json['auteur'] as Map<String, dynamic>?;
    final montantDemande = json['montantDemande'];
    final frais = json['frais'];
    final montantNet = json['montantNet'];
    final soldeApres = json['soldeApres'];

    return RetraitEntity(
      uuid: json['uuid']?.toString() ?? '',
      montantDemande: montantDemande is num ? montantDemande.toInt() : 0,
      frais: frais is num ? frais.toInt() : 0,
      montantNet: montantNet is num ? montantNet.toInt() : 0,
      statut: json['statut']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      motifEchec: json['motifEchec']?.toString(),
      soldeApres: soldeApres is num ? soldeApres.toInt() : null,
      beneficiaireOperator: beneficiaire?['operator']?.toString(),
      beneficiaireNumeroMasque: beneficiaire?['numeroMasque']?.toString(),
      auteurNom: auteur?['nom']?.toString() ?? '',
      completedAt: json['completedAt']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
