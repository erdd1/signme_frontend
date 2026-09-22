import '../config/app_environment.dart';
import '../router/app_router.dart';

/// Cible résolue d'un deep link : où naviguer, et si ça nécessite d'être
/// connecté au préalable (un lien de reset password doit s'ouvrir même
/// déconnecté ; un lien vers un événement doit attendre la connexion).
class DeepLinkTarget {
  const DeepLinkTarget(this.location, {this.requiresAuth = true});
  final String location;
  final bool requiresAuth;
}

/// Convertit les liens `signme://reset-password?...` (email) et
/// `https://<domaine>/evenements/{uuid}` (partage WhatsApp/App Links/
/// Universal Links) en destination GoRouter.
abstract final class DeepLinkParser {
  static const _scheme = 'signme';
  static const _resetHost = 'reset-password';

  static DeepLinkTarget? resolve(Uri uri) {
    if (uri.scheme == _scheme && _isResetPasswordUri(uri)) {
      return DeepLinkTarget(_resetPasswordLocation(uri), requiresAuth: false);
    }
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      return _resolveWebLink(uri);
    }
    return null;
  }

  static String _resetPasswordLocation(Uri uri) {
    final email = uri.queryParameters['email']?.trim();
    final token = uri.queryParameters['token']?.trim();

    if (email == null ||
        email.isEmpty ||
        token == null ||
        token.isEmpty) {
      return AppRoutes.resetPassword;
    }

    return '${AppRoutes.resetPassword}?'
        'email=${Uri.encodeComponent(email)}&'
        'token=${Uri.encodeComponent(token)}';
  }

  static bool _isResetPasswordUri(Uri uri) {
    if (uri.host == _resetHost) return true;
    final segments = uri.pathSegments;
    return segments.isNotEmpty && segments.last == _resetHost;
  }

  /// Lien de partage web — même domaine que [AppEnvironment.webBaseUrl],
  /// intercepté par Android App Links / iOS Universal Links quand l'app est
  /// installée et le domaine vérifié.
  static DeepLinkTarget? _resolveWebLink(Uri uri) {
    final webHost = Uri.parse(AppEnvironment.webBaseUrl).host;
    if (uri.host != webHost) return null;

    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'evenements') {
      final uuid = segments[1].trim();
      if (uuid.isNotEmpty) {
        return DeepLinkTarget(AppRoutes.evenementDetailPath(uuid));
      }
    }
    return null;
  }
}
