/// Filtres par défaut des écrans "Historique" (année courante) — partagés
/// entre [SyncService] (préchargement au splash) et les `bootstrapProvider`
/// des modules historique (préchargement au login), pour que les points de
/// préchargement produisent exactement la même clé de cache que celle que
/// l'écran lira à l'ouverture.
///
/// [status] est volontairement omis par défaut (tous les statuts remontent :
/// l'historique personnel doit afficher un paiement "en cours de traitement"
/// dès son envoi, pas seulement une fois confirmé) — un module qui n'a
/// réellement besoin que des entrées confirmées (ex. historique des
/// signatures effectuées, toujours synchrone/présentiel) le précise
/// explicitement via ce paramètre.
Map<String, dynamic> defaultHistoriqueFilters({int perPage = 20, String? status}) => {
      'year': DateTime.now().year.toString(),
      if (status != null) 'status': status,
      'per_page': perPage,
    };
