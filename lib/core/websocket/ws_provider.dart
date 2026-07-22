import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ws_client.dart';

/// Provider global du [WsClient].
///
/// Instance unique pendant toute la session. Dispose le client correctement
/// quand le provider est détruit (logout / fermeture de l'app).
final wsClientProvider = Provider<WsClient>((ref) {
  final client = WsClient();
  ref.onDispose(client.dispose);
  return client;
});
