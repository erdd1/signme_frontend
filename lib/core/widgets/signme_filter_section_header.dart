import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// FILTER SECTION HEADER - Icône colorée + titre + description
///
/// Utilisé au-dessus d'un sélecteur (dropdown, etc.) pour donner du contexte
/// visuel à une section de filtre (ex. "Filtrer par quartier de résidence").
///
/// Usage:
/// ```dart
/// SignmeFilterSectionHeader(
///   icon: Icons.location_on_rounded,
///   color: SignmeColors.primaryLight,
///   title: 'Filtrer par quartier de résidence',
///   description: 'Sélectionnez le quartier de résidence',
/// )
/// ```
class SignmeFilterSectionHeader extends StatelessWidget {
  const SignmeFilterSectionHeader({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          ),
          child: Icon(icon, color: color, size: SignmeSpacing.iconSm),
        ),
        const SizedBox(width: SignmeSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
