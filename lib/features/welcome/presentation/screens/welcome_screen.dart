import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/signme_colors.dart';
import '../../../../core/router/app_router.dart';
import '../utils/welcome_data.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/page_indicator.dart';
import '../widgets/welcome_action_buttons.dart';

/// Écran de bienvenue avec onboarding carousel
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _fadeAnimationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeAnimationController = AnimationController(
      duration: WelcomeData.animationDuration,
      vsync: this,
    );
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  /// Passer à la page suivante ou aller à login si dernière page
  void _handleNext() {
    if (_currentPage < WelcomeData.totalPages - 1) {
      _pageController.nextPage(
        duration: WelcomeData.pageTransitionDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  /// Aller directement à la page login (skip)
  void _handleSkip() {
    _navigateToLogin();
  }

  /// Naviguer vers la page de login
  void _navigateToLogin() {
    context.go(AppRoutes.login);
  }

  /// Gérer le changement de page
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      _fadeAnimationController.reset();
      _fadeAnimationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SignmeColors.background,
      body: Column(
        children: [
          // ── Carrousel principal ──────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: WelcomeData.pages
                  .map(
                    (page) => OnboardingPage(
                      page: page,
                      fadeAnimation: _fadeAnimationController,
                    ),
                  )
                  .toList(),
            ),
          ),

          // ── Indicateurs de page ──────────────────────────────────────
          PageIndicator(
            currentPage: _currentPage,
            totalPages: WelcomeData.totalPages,
          ),

          // ── Boutons d'action ─────────────────────────────────────────
          WelcomeActionButtons(
            currentPage: _currentPage,
            totalPages: WelcomeData.totalPages,
            onNext: _handleNext,
            onSkip: _handleSkip,
          ),
        ],
      ),
    );
  }
}
