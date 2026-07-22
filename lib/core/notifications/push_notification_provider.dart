import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'push_notification_service.dart';
import 'push_token_remote_datasource.dart';

final pushTokenRemoteDataSourceProvider = Provider<PushTokenRemoteDataSource>(
  (ref) => PushTokenRemoteDataSource(ref.watch(dioProvider)),
);

/// Route GoRouter en attente suite au tap sur une notification (même
/// mécanisme que pendingDeepLinkProvider pour les liens `signme://`).
final pendingNotificationRouteProvider = StateProvider<String?>((ref) => null);

/// Enregistre le jeton FCM de cet appareil côté serveur — appelé à la
/// connexion. N'interrompt jamais le login en cas d'échec (permission
/// refusée, pas de Google Play Services, etc.).
Future<void> registerDeviceToken(WidgetRef ref) async {
  try {
    final token = await PushNotificationService.instance.getToken();
    if (token == null) return;

    String? timezone;
    try {
      timezone = await FlutterTimezone.getLocalTimezone();
    } catch (_) {
      // Fuseau indisponible — le push d'anniversaire sera simplement ignoré
      // pour cet appareil tant qu'aucun fuseau n'est connu.
    }

    await ref.read(pushTokenRemoteDataSourceProvider).register(
          token: token,
          platform: PushNotificationService.instance.platform,
          timezone: timezone,
        );
  } catch (e) {
    if (kDebugMode) debugPrint('[Push] Échec enregistrement du jeton: $e');
  }
}

/// Retire le jeton FCM de cet appareil côté serveur — appelé à la déconnexion.
Future<void> unregisterDeviceToken(WidgetRef ref) async {
  try {
    final token = await PushNotificationService.instance.getToken();
    if (token == null) return;
    await ref.read(pushTokenRemoteDataSourceProvider).unregister(token);
  } catch (_) {}
}

bool _deviceTokenRegisteredThisSession = false;

/// Filet de sécurité — à appeler à chaque build de MainShell.
///
/// Le ref.listen sur AuthState ne capture que les *transitions* (non connecté
/// → connecté) : si la session était déjà restaurée avant que MainShell ne
/// soit monté pour la première fois (cas courant au démarrage à froid avec
/// une session déjà valide), la transition a déjà eu lieu et n'est jamais
/// rejouée — le jeton ne serait alors jamais enregistré. Cette fonction
/// vérifie directement l'état courant et complète le ref.listen, sans jamais
/// enregistrer deux fois grâce au flag (l'appel serveur est de toute façon
/// idempotent, mais autant éviter l'appel réseau superflu).
void ensureDeviceTokenRegistered(WidgetRef ref, bool isAuthenticated) {
  if (!isAuthenticated || _deviceTokenRegisteredThisSession) return;
  _deviceTokenRegisteredThisSession = true;
  registerDeviceToken(ref);
}

/// Réinitialise le flag à la déconnexion, pour qu'un nouveau login (même
/// utilisateur ou un autre) sur cette session d'application ré-enregistre
/// bien le jeton.
void resetDeviceTokenRegistrationFlag() {
  _deviceTokenRegisteredThisSession = false;
}
