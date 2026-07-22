import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/profile_photo_avatar.dart';
import '../../domain/entities/ancien_entity.dart';

class AncienCard extends StatelessWidget {
  const AncienCard({
    super.key,
    required this.ancien,
    this.onDesignate,
    this.onRevoke,
  });

  final AncienEntity ancien;
  final VoidCallback? onDesignate;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    final bool isDesigned = ancien.isDesigned;

    return Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(
          color: isDesigned
              ? SignmeColors.primaryLight.withOpacity(0.3)
              : SignmeColors.lightGrayBorder,
          width: isDesigned ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: SignmeColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(SignmeSpacing.md),
        child: Column(
          children: [
            // ── Header: Avatar + Nom + Status
            Row(
              children: [
                ProfilePhotoAvatar(
                  photoUrl:
                      ancien.photoUrl.isNotEmpty ? ancien.photoUrl : null,
                  displayName: ancien.nom,
                  radius: 26,
                ),
                const SizedBox(width: SignmeSpacing.md),

                // Nom + Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ancien.nom,
                        style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ancien.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
                      ),
                    ],
                  ),
                ),

                // Badge status (Design System)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDesigned ? SignmeColors.success : SignmeColors.warning).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isDesigned ? '✓ Désigné' : '○ Libre',
                    style: SignmeTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDesigned ? SignmeColors.success : SignmeColors.warning,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            // ── Infos de désignation (si désigné)
            if (isDesigned) ...[
              const SizedBox(height: SignmeSpacing.md),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              const SizedBox(height: SignmeSpacing.md),

              _infoLine(Icons.calendar_month_rounded, ancien.monthYearLabel),
              const SizedBox(height: 6),
              _infoLine(
                isDesigned && (ancien.joursTravail == null || ancien.joursTravail!.isEmpty)
                    ? Icons.schedule_rounded
                    : Icons.access_time_rounded,
                ancien.availabilityLabel,
                iconColor: SignmeColors.primaryLight,
              ),

              if (ancien.dateFinService != null) ...[
                const SizedBox(height: 6),
                _infoLine(Icons.timer_outlined, 'Expire: ${ancien.dateFinService}', color: SignmeColors.mediumGray),
              ],
            ],

            // ── Actions
            const SizedBox(height: SignmeSpacing.lg),
            Row(
              children: [
                if (!isDesigned)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.person_add_rounded,
                      label: 'Désigner',
                      color: SignmeColors.primaryLight,
                      onPressed: onDesignate,
                    ),
                  )
                else
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.person_remove_rounded,
                      label: 'Révoquer',
                      color: SignmeColors.error,
                      onPressed: onRevoke,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoLine(IconData icon, String text, {Color? iconColor, Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? SignmeColors.mediumGray),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: SignmeTypography.bodySmall.copyWith(
              color: color ?? SignmeColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: SignmeTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
