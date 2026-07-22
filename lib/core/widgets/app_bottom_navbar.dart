import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design_system/index.dart';
import '../constants/app_strings.dart';
import '../permissions/app_permissions.dart';

// ============================================================================
// APP BOTTOM NAVBAR - Custom Floating Navigation Bar
// ============================================================================

/// Custom floating bottom navigation bar with rounded container design
/// 
/// Features:
/// - Floating container with rounded corners and shadow
/// - Horizontal padding for modern look
/// - SafeArea integration for edge-to-edge support
/// - Smooth animations on tab changes
/// - Icon + Label design consistent with design system
/// - Perfect for maintaining IndexedStack state
/// 
/// Usage:
/// ```dart
/// AppBottomNavbar(
///   tabs: tabs,
///   currentIndex: currentIndex,
///   onNavTap: (tab) => onTap(context, tab),
/// )
/// ```
class AppBottomNavbar extends StatelessWidget {
  const AppBottomNavbar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onNavTap,
    this.backgroundColor,
    this.elevation = 12,
    this.horizontalPadding = 16,
    this.bottomPadding = 12,
  });

  final List<NavTab> tabs;
  final int currentIndex;
  final Function(NavTab) onNavTap;
  final Color? backgroundColor;
  final double elevation;
  final double horizontalPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          12,
          horizontalPadding,
          bottomPadding,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: elevation,
                offset: Offset(0, -elevation / 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: _buildCenteredNavbar(),
          ),
        ),
      ),
    );
  }

  /// Construit une navbar centrée avec le FAB toujours au milieu
  Widget _buildCenteredNavbar() {
    final leftCount = (tabs.length / 2).floor();
    final rightCount = tabs.length - leftCount;
    final isLeftSmaller = leftCount < rightCount;

    final leftTabs = tabs.take(leftCount).toList();
    final rightTabs = tabs.skip(leftCount).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── Côté gauche ────────────────────────────────
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLeftSmaller) const Spacer(),
              ...leftTabs.map((tab) {
                final isActive = currentIndex == tabs.indexOf(tab);
                return _NavBarItem(
                  tab: tab,
                  isActive: isActive,
                  onTap: () => onNavTap(tab),
                );
              }).toList(),
              if (isLeftSmaller) const Spacer(),
            ],
          ),
        ),

        // ── Notch pour le FAB (vraiment centré) ────────
        const SizedBox(width: 60),

        // ── Côté droit ────────────────────────────────
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLeftSmaller) const Spacer(),
              ...rightTabs.map((tab) {
                final isActive = currentIndex == tabs.indexOf(tab);
                return _NavBarItem(
                  tab: tab,
                  isActive: isActive,
                  onTap: () => onNavTap(tab),
                );
              }).toList(),
              if (!isLeftSmaller) const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual navigation bar item with icon and label
class _NavBarItem extends StatefulWidget {
  const _NavBarItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final NavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _scaleController.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconPath = switch (widget.tab) {
      NavTab.home => 'assets/images/accueil.png',
      NavTab.finances => 'assets/images/finances.png',
      NavTab.historique => 'assets/images/historique.png',
      NavTab.profile => 'assets/images/utilisateur_profil.png',
      NavTab.maCarte => 'assets/images/carte.png',
    };

    final label = switch (widget.tab) {
      NavTab.home => AppStrings.home,
      NavTab.finances => AppStrings.finances,
      NavTab.historique => 'Historique',
      NavTab.profile => 'Profil',
      NavTab.maCarte => AppStrings.maCarte,
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onTap();
        if (widget.isActive) {
          _scaleController.forward();
        }
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? SignmeColors.primaryLight.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                ),
                child: Image.asset(
                  iconPath,
                  width: 14,
                  height: 14,
                  color: widget.isActive
                      ? SignmeColors.primaryLight
                      : SignmeColors.mediumGray,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight:
                      widget.isActive ? FontWeight.w600 : FontWeight.w400,
                  color: widget.isActive
                      ? SignmeColors.primaryLight
                      : SignmeColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
