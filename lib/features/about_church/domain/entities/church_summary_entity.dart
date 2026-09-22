class ChurchSummaryEntity {
  const ChurchSummaryEntity({
    required this.id,
    required this.nom,
    required this.ville,
    this.region,
    this.adresse,
  });

  final int id;
  final String nom;
  final String ville;
  final String? region;
  final String? adresse;

  factory ChurchSummaryEntity.fromJson(Map<String, dynamic> json) {
    return ChurchSummaryEntity(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nom: json['nom']?.toString() ?? '',
      ville: json['ville']?.toString() ?? '',
      region: json['region']?.toString(),
      adresse: json['adresse']?.toString(),
    );
  }
}
