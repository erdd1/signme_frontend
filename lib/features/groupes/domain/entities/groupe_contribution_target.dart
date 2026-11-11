/// Destination d'une contribution ou d'un don fait À un groupe (caisse du
/// groupe) : le groupe et, optionnellement, le communiqué visé (absent = don
/// libre au groupe).
class GroupeContributionTarget {
  const GroupeContributionTarget({
    required this.groupeUuid,
    required this.groupeNom,
    this.communiqueUuid,
    this.communiqueTitre,
  });

  final String groupeUuid;
  final String groupeNom;
  final String? communiqueUuid;
  final String? communiqueTitre;

  bool get estDonLibre => communiqueUuid == null;
}
