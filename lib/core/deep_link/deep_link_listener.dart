import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../router/app_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'deep_link_parser.dart';
import 'deep_link_state.dart';

/// Écoute les liens `signme://` (email reset) et navigue via GoRouter.
class DeepLinkListener extends ConsumerStatefulWidget {
  const DeepLinkListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends ConsumerState<DeepLinkListener> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  DeepLinkTarget? _pendingTarget;

  @override
  void initState() {
    super.initState();
    _bootstrapLinks();
  }

  Future<void> _bootstrapLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _queueNavigation(initial);
      _linkSub = _appLinks.uriLinkStream.listen(_queueNavigation);
    } catch (_) {
      // Plateforme sans deep link ou permission refusée — flux manuel inchangé.
    }
  }

  void _queueNavigation(Uri uri) {
    final target = DeepLinkParser.resolve(uri);
    if (target == null) return;
    _pendingTarget = target;
    ref.read(pendingDeepLinkProvider.notifier).state = target.location;
    _tryNavigate();
  }

  void _tryNavigate() {
    final target = _pendingTarget;
    if (target == null) return;
    if (!ref.read(authNotifierProvider).isInitialized) return;

    // Un lien qui exige d'être connecté (ex: événement partagé) reste en
    // attente tant que l'utilisateur n'a pas terminé sa connexion — la
    // redirection post-login (voir app_router.dart) le consomme ensuite.
    // Un lien de reset password s'ouvre lui immédiatement, connecté ou non.
    if (target.requiresAuth && !ref.read(authNotifierProvider).isAuthenticated) {
      return;
    }

    _pendingTarget = null;
    ref.read(pendingDeepLinkProvider.notifier).state = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(routerProvider).go(target.location);
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isInitialized) _tryNavigate();
    });

    return widget.child;
  }
}
