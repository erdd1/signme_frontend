/// Formatage d'affichage pour l'écran d'accueil.
abstract final class HomeDisplayFormatters {
  static const int maxAuthorNameLength = 20;

  /// Limite le nom de l'auteur à [maxLength] caractères visibles.
  static String authorName(String? name, {int maxLength = maxAuthorNameLength}) {
    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return 'Auteur';
    if (trimmed.length <= maxLength) return trimmed;
    return '${trimmed.substring(0, maxLength)}…';
  }
}
