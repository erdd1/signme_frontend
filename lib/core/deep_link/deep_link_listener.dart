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
  String? _pendingLocation;

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
    final location = DeepLinkParser.toGoRouteLocation(uri);
    if (location == null) return;
    _pendingLocation = location;
    ref.read(pendingDeepLinkProvider.notifier).state = location;
    _tryNavigate();
  }

  void _tryNavigate() {
    final location = _pendingLocation;
    if (location == null) return;
    if (!ref.read(authNotifierProvider).isInitialized) return;

    _pendingLocation = null;
    ref.read(pendingDeepLinkProvider.notifier).state = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(routerProvider).go(location);
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
