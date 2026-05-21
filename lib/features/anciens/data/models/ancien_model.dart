import '../../domain/entities/ancien_entity.dart';

class AncienModel extends AncienEntity {
  const AncienModel({
    required super.userId,
    required super.nom,
    required super.email,
    required super.photoUrl,
    super.isDesigned = false,
    super.designationId,
    super.mois,
    super.annee,
    super.egliseId,
    super.joursTravail,
    super.horairesDebut,
    super.horairesFin,
    super.dateFinService,
  });

  factory AncienModel.fromJson(Map<String, dynamic> json) {
    return AncienModel(
      userId: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      email: json['email']?.toString() ?? json['telephone']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString() ?? '',
      isDesigned: (json['est_designe'] as bool?) ?? false,
      designationId: (json['designation_id'] as num?)?.toInt(),
      mois: (json['mois'] as num?)?.toInt(),
      annee: (json['annee'] as num?)?.toInt(),
      egliseId: (json['eglise_id'] as num?)?.toInt(),
      joursTravail: _parseJours(json['jours_travail']),
      horairesDebut: json['horaire_debut']?.toString(),
      horairesFin: json['horaire_fin']?.toString(),
      dateFinService: null,
    );
  }

  static List<int>? _parseJours(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => (e as num).toInt()).toList();
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'nom': nom,
    'email': email,
    'photoUrl': photoUrl,
    'est_de_service': isDesigned,
    if (designationId != null)
      'designation': {
        'id': designationId,
        'mois': mois,
        'annee': annee,
        'egliseId': egliseId,
        'jours_travail': joursTravail,
        'horaire_debut': horairesDebut,
        'horaire_fin': horairesFin,
        'date_fin_service': dateFinService,
      }
  };
}

