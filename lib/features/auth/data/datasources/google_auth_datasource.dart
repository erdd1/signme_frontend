import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/config/app_environment.dart';
import '../../../../core/errors/exceptions.dart';

/// Déclenche le flux natif Google Sign-In et retourne l'ID token nécessaire
/// à la vérification côté backend.
///
/// `serverClientId` doit être le Client ID OAuth **Web** (pas Android/iOS)
/// créé dans Google Cloud Console : c'est lui qui détermine l'audience (aud)
/// de l'ID token, que le backend vérifie via [GoogleTokenVerifier].
class GoogleAuthDataSource {
  GoogleAuthDataSource()
      : _googleSignIn = GoogleSignIn(
          scopes: const ['email'],
          serverClientId: AppEnvironment.googleServerClientId.isEmpty
              ? null
              : AppEnvironment.googleServerClientId,
        );

  final GoogleSignIn _googleSignIn;

  /// Lance la sélection de compte Google et retourne l'ID token.
  ///
  /// Retourne `null` si l'utilisateur annule (pas une erreur). Lève
  /// [AuthException] si Google ne fournit pas d'ID token exploitable.
  Future<String?> signInAndGetIdToken() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null; // Annulé par l'utilisateur

    final authentication = await account.authentication;
    final idToken = authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw AuthException(
        message: 'Google n\'a pas fourni de jeton d\'identification valide.',
      );
    }

    return idToken;
  }

  /// Déconnecte le compte Google côté client (n'affecte pas la session
  /// SignMe elle-même, gérée séparément).
  Future<void> signOut() => _googleSignIn.signOut();
}
