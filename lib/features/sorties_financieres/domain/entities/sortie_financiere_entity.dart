class SortieFinanciereEntity {
  const SortieFinanciereEntity({
    required this.uuid,
    required this.type,
    required this.statut,
    required this.montant,
    required this.description,
    this.reference,
    this.motifRejet,
    this.soldeApres,
    required this.auteurNom,
    this.validatedByNom,
    this.validatedAt,
    required this.createdAt,
  });

  final String uuid;
  final String type;       // 'simple' | 'frais'
  final String statut;     // 'approved' | 'pending' | 'rejected'
  final int montant;
  final String description;
  final String? reference;
  final String? motifRejet;
  final int? soldeApres;
  final String auteurNom;
  final String? validatedByNom;
  final String? validatedAt;
  final String createdAt;

  bool get isSimple   => type   == 'simple';
  bool get isFrais    => type   == 'frais';
  bool get isPending  => statut == 'pending';
  bool get isApproved => statut == 'approved';
  bool get isRejected => statut == 'rejected';
  
  bool get canDelete  => (isSimple && isApproved) || (isFrais && isPending);
  bool get canEdit    => isSimple && isApproved;

  factory SortieFinanciereEntity.fromJson(Map<String, dynamic> json) {
    final auteur = json['auteur'] as Map<String, dynamic>?;
    final validatedBy = json['validatedBy'] as Map<String, dynamic>?;
    final montant = json['montant'];
    final soldeApres = json['soldeApres'];

    return SortieFinanciereEntity(
      uuid:           json['uuid']?.toString() ?? '',
      type:           json['type']?.toString() ?? '',
      statut:         json['statut']?.toString() ?? '',
      montant:        montant is num ? montant.toInt() : 0,
      description:    json['description']?.toString() ?? '',
      reference:      json['reference']?.toString(),
      motifRejet:     json['motifRejet']?.toString(),
      soldeApres:     soldeApres is num ? soldeApres.toInt() : null,
      auteurNom:      auteur?['nom']?.toString() ?? '',
      validatedByNom: validatedBy?['nom']?.toString(),
      validatedAt:    json['validatedAt']?.toString(),
      createdAt:      json['createdAt']?.toString() ?? '',
    );
  }
}
