import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../router/app_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'push_notification_provider.dart';
import 'push_notification_service.dart';

/// Écoute les notifications push (tap) et navigue via GoRouter — même
/// mécanisme que DeepLinkListener pour les liens `signme://`.
class PushNotificationListener extends ConsumerStatefulWidget {
  const PushNotificationListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushNotificationListener> createState() => _PushNotificationListenerState();
}

class _PushNotificationListenerState extends ConsumerState<PushNotificationListener> {
  String? _pendingLocation;
  StreamSubscription<String>? _tokenRefreshSub;

  @override
  void initState() {
    super.initState();
    PushNotificationService.instance.initialize(onNotificationTap: _queueNavigation);

    // Le jeton FCM peut être renouvelé par le système (réinstallation,
    // restauration, rotation périodique) — le ré-enregistrer aussitôt tant
    // que l'utilisateur est connecté, sinon les notifications s'arrêtent
    // silencieusement pour cet appareil.
    _tokenRefreshSub = PushNotificationService.instance.onTokenRefresh.listen((_) {
      if (ref.read(authNotifierProvider).isAuthenticated) {
        registerDeviceToken(ref);
      }
    });
  }

  @override
  void dispose() {
    _tokenRefreshSub?.cancel();
    super.dispose();
  }

  void _queueNavigation(Map<String, dynamic> data) {
    final location = _resolveRoute(data);
    _pendingLocation = location;
    ref.read(pendingNotificationRouteProvider.notifier).state = location;
    _tryNavigate();
  }

  String _resolveRoute(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    switch (type) {
      case 'publication':
        final publicationId = id != null ? int.tryParse(id) : null;
        return publicationId != null
            ? AppRoutes.publicationDetailPath(publicationId)
            : AppRoutes.publications;
      case 'celebration':
        return id != null ? AppRoutes.celebrationDetailPath(id) : AppRoutes.celebrations;
      case 'evenement':
        return id != null ? AppRoutes.evenementDetailPath(id) : AppRoutes.home;
      default:
        return AppRoutes.home;
    }
  }

  void _tryNavigate() {
    final location = _pendingLocation;
    if (location == null) return;
    if (!ref.read(authNotifierProvider).isInitialized) return;
    if (!ref.read(authNotifierProvider).isAuthenticated) return;

    _pendingLocation = null;
    ref.read(pendingNotificationRouteProvider.notifier).state = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(routerProvider).go(location);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isInitialized && next.isAuthenticated) _tryNavigate();
    });

    return widget.child;
  }
}
