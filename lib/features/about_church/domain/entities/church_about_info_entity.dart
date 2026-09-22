/// Infos permanentes du Card principal — district, horaires de culte,
/// activités majeures récurrentes. Saisies par pasteur/secrétaire, distinctes
/// des articles éditoriaux (voir AboutArticleEntity).
class ChurchAboutInfoEntity {
  const ChurchAboutInfoEntity({
    this.district,
    this.horairesCulte,
    this.activitesMajeures = const [],
  });

  final String? district;
  final String? horairesCulte;

  /// Max 5 entrées, chacune tenant sur une ligne (validé côté backend).
  final List<String> activitesMajeures;

  factory ChurchAboutInfoEntity.fromJson(Map<String, dynamic> json) {
    return ChurchAboutInfoEntity(
      district: json['district']?.toString(),
      horairesCulte: json['horairesCulte']?.toString(),
      activitesMajeures: (json['activitesMajeures'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  static const empty = ChurchAboutInfoEntity();
}
