import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../auth/presentation/providers/auth_provider.dart';

/// Écran de démarrage — vérifie si l'utilisateur est déjà connecté
/// Affiché pendant la restauration de session (stockage sécurisé)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double>   _scale;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Surveille l'état auth — redirige quand initialisé
    ref.listen(authNotifierProvider, (_, next) {
      if (!next.isInitialized) return;
      if (next.isAuthenticated) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.login);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Logo animé ──────────────────────────────────────────────
              ScaleTransition(
                scale: _scale,
                child: FadeTransition(
                  opacity: _fade,
                  child: Container(
                    width:  110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:  Colors.black.withOpacity(0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.verified_user_rounded,
                          size: 52,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Nom app ─────────────────────────────────────────────────
              FadeTransition(
                opacity: _fade,
                child: Text(
                  AppStrings.appName,
                  style: GoogleFonts.poppins(
                    fontSize:   26,
                    fontWeight: FontWeight.bold,
                    color:      Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // ── Loader ──────────────────────────────────────────────────
              const SizedBox(
                width:  28,
                height: 28,
                child:  CircularProgressIndicator(
                  strokeWidth:  2.5,
                  valueColor:   AlwaysStoppedAnimation(Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
