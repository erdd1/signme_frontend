/// Statistiques financières agrégées des contributions d'un tableau de bord
/// trésorerie — calculées côté backend à partir des filtres actifs.
///
/// Formule : [totalPaye] = [netRecu] + [totalFrais].
class ContributionsTreasuryStatsEntity {
  const ContributionsTreasuryStatsEntity({
    required this.totalPaye,
    required this.totalFrais,
    required this.netRecu,
    required this.count,
  });

  /// Montant total effectivement débité aux contributeurs (montantTotal).
  final int totalPaye;

  /// Somme des frais de transaction prélevés.
  final int totalFrais;

  /// Montant net revenant à l'église après déduction des frais (montant).
  final int netRecu;

  /// Nombre de contributions correspondant aux filtres.
  final int count;

  static int _asInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  factory ContributionsTreasuryStatsEntity.fromJson(Map<String, dynamic> json) =>
      ContributionsTreasuryStatsEntity(
        totalPaye:  _asInt(json['total_paye']),
        totalFrais: _asInt(json['total_frais']),
        netRecu:    _asInt(json['net_recu']),
        count:      _asInt(json['count']),
      );

  /// Stats vides (état initial avant la réponse du backend).
  static const empty = ContributionsTreasuryStatsEntity(
    totalPaye: 0, totalFrais: 0, netRecu: 0, count: 0,
  );
}
