/// Statistiques "Mes dépenses" — total à vie, ce mois, cette année, total sur
/// la période (mois/année) actuellement sélectionnée par le filtre, et
/// répartition à vie entre offrandes signatures et offrandes événements.
class MesDepensesStatsEntity {
  const MesDepensesStatsEntity({
    this.totalDonne = 0,
    this.ceMois = 0,
    this.cetteAnnee = 0,
    this.totalEvenements = 0,
    this.totalSignatures = 0,
    this.anneeSelectionnee,
    this.moisSelectionne,
    this.totalPeriodeSelectionnee = 0,
  });

  final int totalDonne;
  final int ceMois;
  final int cetteAnnee;

  /// Total à vie des offrandes liées aux événements (frais inclus).
  final int totalEvenements;

  /// Total à vie des offrandes liées aux signatures, présentiel et à
  /// distance confondues (frais inclus).
  final int totalSignatures;

  final int? anneeSelectionnee;
  final int? moisSelectionne;
  final int totalPeriodeSelectionnee;

  factory MesDepensesStatsEntity.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    int? asIntOrNull(dynamic v) => v == null ? null : asInt(v);
    final periode = json['periodeSelectionnee'] as Map<String, dynamic>?;
    return MesDepensesStatsEntity(
      totalDonne: asInt(json['totalDonne']),
      ceMois: asInt(json['ceMois']),
      cetteAnnee: asInt(json['cetteAnnee']),
      totalEvenements: asInt(json['totalEvenements']),
      totalSignatures: asInt(json['totalSignatures']),
      anneeSelectionnee: asIntOrNull(periode?['annee']),
      moisSelectionne: asIntOrNull(periode?['mois']),
      totalPeriodeSelectionnee: asInt(periode?['total']),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalDonne': totalDonne,
        'ceMois': ceMois,
        'cetteAnnee': cetteAnnee,
        'totalEvenements': totalEvenements,
        'totalSignatures': totalSignatures,
        'periodeSelectionnee': {
          'annee': anneeSelectionnee,
          'mois': moisSelectionne,
          'total': totalPeriodeSelectionnee,
        },
      };
}