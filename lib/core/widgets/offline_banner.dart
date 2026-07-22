import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../providers/connectivity_provider.dart';

/// Bannière discrète "Mode hors ligne" affichée dans le [MainShell].
///
/// - Visible uniquement quand `connectivityProvider` émet [false].
/// - Animée (slide + fade) pour une apparition/disparition fluide.
/// - Non-intrusive : occupe la largeur totale mais reste en haut de l'écran.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);

    // Pendant l'initialisation du stream, on considère l'app comme en ligne.
    final isOnline = connectivity.asData?.value ?? true;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      offset: isOnline ? const Offset(0, -1) : Offset.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isOnline ? 0.0 : 1.0,
        child: _BannerContent(),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.warning.withOpacity(0.95),
              AppColors.warning.withOpacity(0.85),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mode hors ligne — Données en cache',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
