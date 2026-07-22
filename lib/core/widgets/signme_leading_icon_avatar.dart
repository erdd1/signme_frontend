import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// LEADING ICON AVATAR - Cercle coloré + icône
///
/// Utilisé en tête de ligne/carte quand il n'y a pas de photo pertinente
/// (ex. cartes de contribution), pour donner un repère visuel rapide.
///
/// Usage:
/// ```dart
/// SignmeLeadingIconAvatar(
///   icon: Icons.favorite_rounded,
///   color: SignmeColors.primaryLight,
/// )
/// ```
class SignmeLeadingIconAvatar extends StatelessWidget {
  const SignmeLeadingIconAvatar({
    super.key,
    required this.icon,
    this.color = SignmeColors.primaryLight,
    this.size = 44,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
