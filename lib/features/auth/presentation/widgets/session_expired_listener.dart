import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';

/// Affiche le message de session expirée (retour login fluide).
class SessionExpiredListener extends ConsumerStatefulWidget {
  const SessionExpiredListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionExpiredListener> createState() =>
      _SessionExpiredListenerState();
}

class _SessionExpiredListenerState extends ConsumerState<SessionExpiredListener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyIfNeeded());
  }

  void _notifyIfNeeded() {
    if (!mounted) return;
    final auth = ref.read(authNotifierProvider);
    if (!auth.sessionExpiredNotice) return;

    AppSnackbar.info(context, AppStrings.sessionExpired);
    ref.read(authNotifierProvider.notifier).clearSessionExpiredNotice();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      final wasExpired = previous?.sessionExpiredNotice ?? false;
      if (next.sessionExpiredNotice && !wasExpired) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _notifyIfNeeded());
      }
    });

    return widget.child;
  }
}
