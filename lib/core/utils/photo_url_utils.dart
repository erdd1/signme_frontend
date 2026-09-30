/// Normalise les URLs de photos renvoyées par l'API (Cloudinary, etc.).
String? normalizePhotoUrl(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty || raw == 'null') return null;
  if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
    return null;
  }
  if (raw.startsWith('http://')) {
    return 'https://${raw.substring(7)}';
  }
  return raw;
}

/// URL affichable d'une photo de profil. Le backend enregistre déjà les
/// photos pré-redimensionnées (512×512) à l'upload — aucune transformation
/// côté client n'est nécessaire ou possible (contrairement à Cloudinary, qui
/// supportait un redimensionnement à la volée via l'URL).
String profilePhotoDisplayUrl(String? url) => normalizePhotoUrl(url) ?? '';

/// Évite un cache HTTP obsolète après remplacement de la photo.
/// [bust] doit être stable (ex. fixé une fois après upload), sinon chaque
/// rebuild change l'URL et relance un chargement infini.
String photoUrlWithCacheBust(String url, {required int bust}) {
  final base = normalizePhotoUrl(url);
  if (base == null) return url;
  final uri = Uri.tryParse(base);
  if (uri == null) return base;
  return uri.replace(queryParameters: {
    ...uri.queryParameters,
    'v': '$bust',
  }).toString();
}
