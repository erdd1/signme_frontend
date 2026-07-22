import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design_system/index.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/sync_service.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../widgets/animated_dots_loader.dart';
import '../widgets/app_logo_card.dart';
import '../widgets/gradient_text.dart';

/// Délai maximum d'attente du sync initial avant de naviguer quand même
/// (évite de bloquer le splash indéfiniment si le réseau est très lent).
const Duration _kMaxSyncWait = Duration(seconds: 8);


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _navigating = false;

  // Logo card: scale up from 0.6 with a gentle spring
  late final Animation<double> _logoScale;

  // Fade in for all content
  late final Animation<double> _fade;

  // Subtle vertical slide for the app name
  late final Animation<Offset> _nameSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: SignmeSpacing.animationSlow, // 500 ms
    );

    _logoScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Attend la fin du préchargement offline-first (si authentifié) avant de
  /// naviguer, pour ne jamais montrer un écran Home qui se recharge sous les
  /// yeux de l'utilisateur. Bornée par [_kMaxSyncWait] pour ne pas bloquer le
  /// splash indéfiniment en cas de réseau très lent ou indisponible.
  Future<void> _proceed(bool isAuthenticated) async {
    if (_navigating) return;
    _navigating = true;

    if (isAuthenticated) {
      try {
        await ref
            .read(syncServiceProvider)
            .initialSync()
            .timeout(_kMaxSyncWait, onTimeout: () {});
      } catch (_) {
        // Le sync est best-effort : on navigue quand même, les écrans
        // afficheront le dernier cache disponible.
      }
    }

    if (!mounted) return;
    context.go(isAuthenticated ? AppRoutes.home : AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    // Navigue quand l'état Auth est résolu, après préchargement des données.
    ref.listen<AuthState>(authNotifierProvider, (_, AuthState next) {
      if (!next.isInitialized) return;
      _proceed(next.isAuthenticated);
    });

    return Scaffold(
      backgroundColor: SignmeColors.background, // near-white #FAFAFA
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Logo card ──────────────────────────────────────────────
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _fade,
                  child: const AppLogoCard(size: 108),
                ),
              ),

              const SizedBox(height: SignmeSpacing.xl), // 20

              // ── App name ───────────────────────────────────────────────
              FadeTransition(
                opacity: _fade,
                  child: SlideTransition(
                    position: _nameSlide,
                    child: const GradientText('SignMe'),
                  )
              ),

              const SizedBox(height: SignmeSpacing.sm), // 8

              // ── Tagline ────────────────────────────────────────────────
              FadeTransition(
                opacity: _fade,
                child: Text(
                  'Signature des cartes de sainte cene',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                    color: SignmeColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: SignmeSpacing.massive), // 64

              // ── Animated dots loader ───────────────────────────────────
              FadeTransition(
                opacity: _fade,
                child: const AnimatedDotsLoader(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
