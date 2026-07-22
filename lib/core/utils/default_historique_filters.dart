/// Filtres par défaut des écrans "Historique" (année courante, signatures
/// confirmées) — partagés entre [SyncService] (préchargement au splash) et
/// les `bootstrapProvider` des modules historique (préchargement au login),
/// pour que les trois points de préchargement produisent exactement la même
/// clé de cache que celle que l'écran lira à l'ouverture.
Map<String, dynamic> defaultHistoriqueFilters({int perPage = 20}) => {
      'year': DateTime.now().year.toString(),
      'status': 'completed',
      'per_page': perPage,
    };
