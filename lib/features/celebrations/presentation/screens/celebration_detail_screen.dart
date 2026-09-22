import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/entities/celebration_entity.dart';
import '../providers/celebrations_provider.dart';
import '../widgets/celebration_animation_config.dart';
import '../widgets/pinata_widget.dart';

/// Boîte de célébration plein écran — atteinte en tapant une card dans la
/// liste OU via le deep-link d'une notification push (même route dans les
/// deux cas). Confettis + message personnalisé ; toujours facile à fermer
/// (bouton croix, bouton "Fermer", et le geste retour système).
class CelebrationDetailScreen extends ConsumerStatefulWidget {
  const CelebrationDetailScreen({super.key, required this.uuid});

  final String uuid;

  @override
  ConsumerState<CelebrationDetailScreen> createState() => _CelebrationDetailScreenState();
}

class _CelebrationDetailScreenState extends ConsumerState<CelebrationDetailScreen> {
  late final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 4));
  bool _markedRead = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _confettiController.play());
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _markReadOnce(CelebrationEntity celebration) {
    if (_markedRead || celebration.isRead) return;
    _markedRead = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(celebrationsProvider.notifier).markRead(celebration.uuid);
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      // Arrivée directe via deep-link (app était fermée) : pas de page
      // précédente dans la pile — retour à l'accueil plutôt que bloqué.
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(celebrationByUuidProvider(widget.uuid));

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: const Color(0xE6001F3F), // primaryDark ~90% opaque
        body: async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (e, _) => _ErrorContent(onClose: _close),
          data: (celebration) {
            _markReadOnce(celebration);
            final config = animationFor(celebration.animationKey);

            return Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    numberOfParticles: config.numberOfParticles,
                    colors: config.colors,
                    createParticlePath: particlePathFor(config.shape),
                    gravity: 0.25,
                    shouldLoop: false,
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                          onPressed: _close,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.xl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: SignmeSpacing.lg),
                              celebration.type == 'anniversaire'
                                  ? const PinataWidget(size: 150)
                                  : Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: config.iconColor.withOpacity(0.5),
                                            blurRadius: 24,
                                            spreadRadius: 4,
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(config.icon, size: 64, color: config.iconColor),
                                    ),
                              const SizedBox(height: SignmeSpacing.xl),
                              Text(
                                celebration.titre,
                                textAlign: TextAlign.center,
                                style: SignmeTypography.headlineMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: SignmeSpacing.lg),
                              Container(
                                padding: const EdgeInsets.all(SignmeSpacing.lg),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
                                ),
                                child: Text(
                                  celebration.message,
                                  textAlign: TextAlign.center,
                                  style: SignmeTypography.bodyLarge.copyWith(
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: SignmeSpacing.xxl),
                              SizedBox(
                                width: double.infinity,
                                child: SignmePrimaryButton(
                                  label: 'Fermer',
                                  onPressed: _close,
                                ),
                              ),
                              const SizedBox(height: SignmeSpacing.lg),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SignmeSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 48),
            const SizedBox(height: SignmeSpacing.md),
            Text(
              'Impossible de charger cette célébration.',
              textAlign: TextAlign.center,
              style: SignmeTypography.bodyLarge.copyWith(color: Colors.white),
            ),
            const SizedBox(height: SignmeSpacing.lg),
            SignmePrimaryButton(label: 'Fermer', onPressed: onClose),
          ],
        ),
      ),
    );
  }
}
