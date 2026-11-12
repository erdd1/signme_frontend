/// Moteur de recherche affiché dans le navigateur intégré. Ce sont les VRAIES
/// pages de résultats : le chrétien n'a plus besoin de quitter SignMe.
enum MoteurRecherche {
  google,
  youtube;

  String get libelle => switch (this) {
        MoteurRecherche.google => 'Google',
        MoteurRecherche.youtube => 'YouTube',
      };

  /// Page de résultats pour [requete] (le mot « chant » oriente vers la louange).
  Uri urlPour(String requete) {
    final q = requete.toLowerCase().contains('chant') ? requete : '$requete chant';
    return switch (this) {
      MoteurRecherche.google => Uri.https('www.google.com', '/search', {'q': q}),
      MoteurRecherche.youtube => Uri.https('m.youtube.com', '/results', {'search_query': q}),
    };
  }
}

/// Reconnaît, dans l'adresse affichée par le navigateur, ce qui est un chant à
/// retenir : une vidéo YouTube (enregistrée toute seule) ou une page quelconque
/// (enregistrée sur demande). Les pages de résultats ne sont jamais des chants.
abstract final class ChantNavigateur {
  static final _idVideo = RegExp(r'^[A-Za-z0-9_-]{6,20}$');

  static String _hote(Uri uri) =>
      uri.host.toLowerCase().replaceFirst(RegExp(r'^(www|m|music)\.'), '');

  /// Identifiant de la vidéo si [uri] est une page de lecture YouTube.
  static String? idVideoYoutube(Uri uri) {
    final hote = _hote(uri);
    String? id;

    if (hote == 'youtu.be') {
      id = uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    } else if (hote == 'youtube.com') {
      if (uri.path == '/watch') {
        id = uri.queryParameters['v'];
      } else if (uri.pathSegments.length >= 2 && const {'shorts', 'embed', 'live'}.contains(uri.pathSegments.first)) {
        id = uri.pathSegments[1];
      }
    }

    return id != null && _idVideo.hasMatch(id) ? id : null;
  }

  /// Page de résultats d'un moteur (Google, YouTube…) : jamais un chant en soi.
  static bool estPageDeRecherche(Uri uri) {
    final hote = _hote(uri);
    final chemin = uri.path;

    if (hote == 'youtube.com') return chemin == '/results' || chemin == '/' || chemin.isEmpty;
    if (hote.startsWith('google.')) return chemin.startsWith('/search') || chemin == '/' || chemin.isEmpty;
    return false;
  }

  /// Une page web qu'on peut garder dans « Mes chants » (http/https, pas une page de résultats).
  static bool estEnregistrable(Uri uri) =>
      (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty && !estPageDeRecherche(uri);

  /// Titre propre d'une page : retire le suffixe « - YouTube » et les espaces.
  static String titrePropre(String? brut, {required String repli}) {
    var titre = (brut ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
    titre = titre.replaceFirst(RegExp(r'\s*[-–|]\s*YouTube$', caseSensitive: false), '').trim();
    if (titre.isEmpty || titre.toLowerCase() == 'youtube') return repli;
    return titre.length > 200 ? titre.substring(0, 200) : titre;
  }

  /// Vignette officielle d'une vidéo YouTube (adresse publique, aucun appel d'API).
  static String vignette(String idVideo) => 'https://i.ytimg.com/vi/$idVideo/mqdefault.jpg';

  /// Seuls http et https sont suivis dans le navigateur : jamais intent:, market:, file:, javascript:…
  static bool schemeAutorise(String url) {
    final scheme = Uri.tryParse(url)?.scheme.toLowerCase();
    return scheme == 'http' || scheme == 'https' || scheme == 'about';
  }
}
