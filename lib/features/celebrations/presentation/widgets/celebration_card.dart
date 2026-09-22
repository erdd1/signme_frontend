import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/index.dart';
import '../../domain/entities/celebration_entity.dart';
import 'celebration_animation_config.dart';

class CelebrationCard extends StatelessWidget {
  const CelebrationCard({super.key, required this.celebration, required this.onTap});

  final CelebrationEntity celebration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final config = animationFor(celebration.animationKey);
    final date = DateTime.tryParse(celebration.occursOn);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(SignmeSpacing.md),
        decoration: BoxDecoration(
          color: SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
          border: Border.all(color: SignmeColors.lightGrayBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: config.iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              ),
              child: Icon(config.icon, color: config.iconColor, size: 24),
            ),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    celebration.label.toUpperCase(),
                    style: SignmeTypography.labelSmall.copyWith(
                      color: SignmeColors.primaryLight,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    celebration.titre,
                    style: SignmeTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    celebration.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SignmeSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (date != null)
                  Text(
                    DateFormat('dd/MM/yyyy').format(date),
                    style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
                  ),
                const SizedBox(height: SignmeSpacing.sm),
                if (!celebration.isRead)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: SignmeColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
