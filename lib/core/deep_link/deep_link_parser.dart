import '../router/app_router.dart';

/// Convertit les URI `signme://reset-password?...` en chemin GoRouter.
abstract final class DeepLinkParser {
  static const _scheme = 'signme';
  static const _resetHost = 'reset-password';

  static String? toGoRouteLocation(Uri uri) {
    if (uri.scheme != _scheme) return null;
    if (!_isResetPasswordUri(uri)) return null;

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
}
