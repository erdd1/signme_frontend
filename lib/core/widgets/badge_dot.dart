import 'package:flutter/material.dart';
import '../design_system/index.dart';
import '../../features/badge/domain/entities/badge_count_entity.dart';

/// Widget badge rouge réutilisable — Design System SignMe
///
/// Utilisé à la fois par [_NavItem] (BottomNavBar) et [_MenuItem] (RoleMenuDrawer).
/// Affiche un cercle rouge avec texte blanc positionné en haut à droite de [child].
///
/// Règle d'affichage :
///   count == 0  → invisible (aucun badge)
///   1–9         → chiffre exact
///   10+         → "9+"
class BadgeDot extends StatelessWidget {
  const BadgeDot({
    super.key,
    required this.count,
    required this.child,
  });

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    final label = BadgeCountEntity.formatCount(count);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -5,
          right: -6,
          child: _BadgePill(label: label),
        ),
      ],
    );
  }
}

/// Pastille rouge avec texte blanc — interne au widget BadgeDot
class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    // "9+" est plus large → adapter la largeur minimale
    final isWide = label.length > 1;

    return Container(
      constraints: BoxConstraints(
        minWidth: isWide ? 20 : 16,
        minHeight: 16,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 4 : 2,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: SignmeColors.error,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SignmeColors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: SignmeColors.error.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: SignmeColors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}
