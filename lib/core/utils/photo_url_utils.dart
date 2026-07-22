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

/// URL Cloudinary redimensionnée pour avatars (chargement plus rapide sur mobile).
String profilePhotoDisplayUrl(String? url, {int size = 256}) {
  final base = normalizePhotoUrl(url);
  if (base == null) return '';

  if (!base.contains('res.cloudinary.com')) {
    return base;
  }

  const uploadSegment = '/upload/';
  final uploadIndex = base.indexOf(uploadSegment);
  if (uploadIndex < 0) return base;

  final afterUpload = base.substring(uploadIndex + uploadSegment.length);
  if (afterUpload.startsWith('c_') || afterUpload.contains('/c_')) {
    return base;
  }

  final transform = 'c_fill,w_$size,h_$size,f_jpg,q_auto/';
  return '${base.substring(0, uploadIndex + uploadSegment.length)}$transform$afterUpload';
}

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
