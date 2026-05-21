import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/domain/entities/auth_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Shell principal — Bottom Navigation adaptatif par rôle + FAB Signer
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.auth?.user;

    // Si l'utilisateur est déconnecté, le routeur va rediriger automatiquement
    // On affiche juste le child sans les contrôles de navigation
    if (!authState.isAuthenticated || user == null) {
      return child;
    }

    final tabs      = AppPermissions.getNavTabs(user);
    final currentIdx = _currentIndex(context, tabs);

    return Scaffold(
      backgroundColor: AppColors.background,
      body:            child,
      floatingActionButton:         _buildFab(context, user),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:          _buildBottomNav(context, tabs, currentIdx),
    );
  }

  // ── Index actif calculé depuis la route ─────────────────────────────────
  int _currentIndex(BuildContext ctx, List<NavTab> tabs) {
    final loc = GoRouterState.of(ctx).matchedLocation;
    for (int i = 0; i < tabs.length; i++) {
      switch (tabs[i]) {
        case NavTab.home:       if (loc.startsWith(AppRoutes.home))       return i;
        case NavTab.finances:   if (loc.startsWith(AppRoutes.finances))   return i;
        case NavTab.historique: if (loc.startsWith(AppRoutes.historique)) return i;
        case NavTab.maCarte:    if (loc.startsWith(AppRoutes.maCarte))    return i;
      }
    }
    return 0;
  }

  void _onNavTap(BuildContext ctx, NavTab tab) {
    switch (tab) {
      case NavTab.home:       ctx.go(AppRoutes.home);
      case NavTab.finances:   ctx.go(AppRoutes.finances);
      case NavTab.historique: ctx.go(AppRoutes.historique);
      case NavTab.maCarte:    ctx.go(AppRoutes.maCarte);
    }
  }

  // ── FAB ─────────────────────────────────────────────────────────────────
  Widget _buildFab(BuildContext ctx, UserEntity user) {
    // Tous les utilisateurs actifs peuvent accéder à Signer
    if (!user.actif) return const SizedBox.shrink();

    return Container(
      width:  64, height: 64,
      decoration: BoxDecoration(
        gradient:     AppColors.primaryGradient,
        shape:        BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color:      AppColors.primary.withOpacity(0.35),
            blurRadius: 16,
            offset:     const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color:        Colors.transparent,
        shape:        const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => ctx.push(AppRoutes.signer),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  // ── Bottom Navigation ────────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext ctx, List<NavTab> tabs, int currentIndex) {
    // Calcule le nombre de slots de chaque côté du FAB
    final half   = tabs.length ~/ 2;
    final leftTabs  = tabs.sublist(0, half);
    final rightTabs = tabs.sublist(half);

    return BottomAppBar(
      height:      72,
      color:       AppColors.navBackground,
      elevation:   8,
      shadowColor: Colors.black26,
      shape:       const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Gauche
          ...leftTabs.map((tab) {
            final idx = tabs.indexOf(tab);
            return _NavItem(
              tab:     tab,
              isActive: currentIndex == idx,
              onTap:   () => _onNavTap(ctx, tab),
            );
          }),

          // Espace FAB
          const SizedBox(width: 56),

          // Droite
          ...rightTabs.map((tab) {
            final idx = tabs.indexOf(tab);
            return _NavItem(
              tab:     tab,
              isActive: currentIndex == idx,
              onTap:   () => _onNavTap(ctx, tab),
            );
          }),
        ],
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.isActive, required this.onTap});
  final NavTab  tab;
  final bool    isActive;
  final VoidCallback onTap;

  IconData get _icon => switch (tab) {
    NavTab.home       => Icons.home_outlined,
    NavTab.finances   => Icons.bar_chart_outlined,
    NavTab.historique => Icons.history_outlined,
    NavTab.maCarte    => Icons.credit_card_outlined,
  };

  IconData get _activeIcon => switch (tab) {
    NavTab.home       => Icons.home_rounded,
    NavTab.finances   => Icons.bar_chart_rounded,
    NavTab.historique => Icons.history_rounded,
    NavTab.maCarte    => Icons.credit_card_rounded,
  };

  String get _label => switch (tab) {
    NavTab.home       => AppStrings.home,
    NavTab.finances   => AppStrings.finances,
    NavTab.historique => AppStrings.historique,
    NavTab.maCarte    => AppStrings.maCarte,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:    onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isActive ? _activeIcon : _icon,
                key:   ValueKey(isActive),
                size:  24,
                color: isActive ? AppColors.navActive : AppColors.navInactive,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _label,
              style: GoogleFonts.poppins(
                fontSize:   10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color:      isActive ? AppColors.navActive : AppColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
