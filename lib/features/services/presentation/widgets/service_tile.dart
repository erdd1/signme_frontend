import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/badge_dot.dart';
import '../../domain/entities/service_entity.dart';

/// Tuile d'un service : pastille arrondie + icône, libellé dessous.
class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key, required this.service, required this.onTap});

  final ServiceEntity service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: service.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: BadgeDot(
                count: service.badgeCount,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: SignmeColors.accentSky,
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusXl),
                  ),
                  child: Icon(service.icon, size: 34, color: SignmeColors.primaryLight),
                ),
              ),
            ),
            const SizedBox(height: SignmeSpacing.sm),
            Text(
              service.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: SignmeTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: SignmeColors.onSurface,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
