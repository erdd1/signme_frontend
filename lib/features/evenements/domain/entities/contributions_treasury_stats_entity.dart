/// Statistiques financieres agregees des contributions d'un tableau de bord
/// tresorerie -- calculees cote backend a partir des filtres actifs.
///
/// Formule : [totalPaye] = [netRecu] + [totalFrais].
class ContributionsTreasuryStatsEntity {
  const ContributionsTreasuryStatsEntity({
    required this.totalPaye,
    required this.totalFrais,
    required this.netRecu,
    required this.count,
    required this.nombreContributeurs,
  });

  /// Montant total effectivement debite aux contributeurs (montantTotal).
  final int totalPaye;

  /// Somme des frais de transaction preleves.
  final int totalFrais;

  /// Montant net revenant a l'eglise apres deduction des frais (montant).
  final int netRecu;

  /// Nombre de contributions correspondant aux filtres.
  final int count;

  /// Nombre de contributeurs uniques (COUNT DISTINCT userId).
  /// Regle : un meme user qui contribue N fois = 1 contributeur.
  /// Si filtre groupe actif : compte 1 fois pour ce groupe (via WHERE).
  final int nombreContributeurs;

  static int _asInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  factory ContributionsTreasuryStatsEntity.fromJson(Map<String, dynamic> json) =>
      ContributionsTreasuryStatsEntity(
        totalPaye:           _asInt(json['total_paye']),
        totalFrais:          _asInt(json['total_frais']),
        netRecu:             _asInt(json['net_recu']),
        count:               _asInt(json['count']),
        nombreContributeurs: _asInt(json['nombre_contributeurs']),
      );

  /// Stats vides (etat initial avant la reponse du backend).
  static const empty = ContributionsTreasuryStatsEntity(
    totalPaye: 0, totalFrais: 0, netRecu: 0, count: 0, nombreContributeurs: 0,
  );
}