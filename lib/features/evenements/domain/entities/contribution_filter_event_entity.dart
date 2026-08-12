/// Événement référencé dans les filtres du tableau de bord contributions —
/// uniquement les événements ayant au moins une contribution "completed".
///
/// Distinct de [EvenementEntity] (beaucoup plus lourd) : cette entité légère
/// est utilisée exclusivement pour peupler le dropdown "Événement" des filtres.
class ContributionFilterEventEntity {
  const ContributionFilterEventEntity({
    required this.id,
    required this.uuid,
    required this.titre,
  });

  final int id;
  final String uuid;
  final String titre;

  factory ContributionFilterEventEntity.fromJson(Map<String, dynamic> json) =>
      ContributionFilterEventEntity(
        id:    (json['id'] as num).toInt(),
        uuid:  json['uuid']?.toString() ?? '',
        titre: json['titre']?.toString() ?? '',
      );
}
