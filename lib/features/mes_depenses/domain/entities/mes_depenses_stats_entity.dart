/// Statistiques "Mes dépenses" — total à vie, ce mois, cette année, et total
/// sur la période (mois/année) actuellement sélectionnée par le filtre.
class MesDepensesStatsEntity {
  const MesDepensesStatsEntity({
    this.totalDonne = 0,
    this.ceMois = 0,
    this.cetteAnnee = 0,
    this.anneeSelectionnee,
    this.moisSelectionne,
    this.totalPeriodeSelectionnee = 0,
  });

  final int totalDonne;
  final int ceMois;
  final int cetteAnnee;
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
      anneeSelectionnee: asIntOrNull(periode?['annee']),
      moisSelectionne: asIntOrNull(periode?['mois']),
      totalPeriodeSelectionnee: asInt(periode?['total']),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalDonne': totalDonne,
        'ceMois': ceMois,
        'cetteAnnee': cetteAnnee,
        'periodeSelectionnee': {
          'annee': anneeSelectionnee,
          'mois': moisSelectionne,
          'total': totalPeriodeSelectionnee,
        },
      };
}
