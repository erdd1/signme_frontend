class SortiesDashboardStatsEntity {
  const SortiesDashboardStatsEntity({
    required this.totalEncaisseGlobal,
    required this.totalFraisGeneres,
    required this.totalSortiesSimples,
    required this.totalSortieFraisValidees,
    required this.sortieFraisEnAttente,
    required this.soldeActuel,
    required this.fraisRestantAVerser,
    required this.periodeEncaisse,
    required this.periodeFrais,
    required this.periodeSortiesSimples,
    required this.periodeSortieFraisVal,
  });

  final int totalEncaisseGlobal;
  final int totalFraisGeneres;
  final int totalSortiesSimples;
  final int totalSortieFraisValidees;
  final int sortieFraisEnAttente;
  final int soldeActuel;
  final int fraisRestantAVerser;
  final int periodeEncaisse;
  final int periodeFrais;
  final int periodeSortiesSimples;
  final int periodeSortieFraisVal;

  static int _asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  factory SortiesDashboardStatsEntity.fromJson(Map<String, dynamic> json) {
    final g = json['global'] as Map<String, dynamic>;
    final p = json['periode'] as Map<String, dynamic>;
    return SortiesDashboardStatsEntity(
      totalEncaisseGlobal:     _asInt(g['total_encaisse']),
      totalFraisGeneres:       _asInt(g['total_frais_generes']),
      totalSortiesSimples:     _asInt(g['total_sorties_simples']),
      totalSortieFraisValidees:_asInt(g['total_sorties_frais_val']),
      sortieFraisEnAttente:    _asInt(g['sorties_frais_en_attente']),
      soldeActuel:             _asInt(g['solde_actuel']),
      fraisRestantAVerser:     _asInt(g['frais_restant_a_verser']),
      periodeEncaisse:         _asInt(p['total_encaisse']),
      periodeFrais:            _asInt(p['total_frais']),
      periodeSortiesSimples:   _asInt(p['sorties_simples']),
      periodeSortieFraisVal:   _asInt(p['sorties_frais_val']),
    );
  }

  static const empty = SortiesDashboardStatsEntity(
    totalEncaisseGlobal: 0, totalFraisGeneres: 0, totalSortiesSimples: 0,
    totalSortieFraisValidees: 0, sortieFraisEnAttente: 0, soldeActuel: 0,
    fraisRestantAVerser: 0, periodeEncaisse: 0, periodeFrais: 0,
    periodeSortiesSimples: 0, periodeSortieFraisVal: 0,
  );
}
