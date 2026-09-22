import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/profile_photo_avatar.dart';
import '../../../auth/domain/entities/user_entity.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
  });

  final UserEntity user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SignmeColors.white,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(SignmeSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            border: Border.all(color: SignmeColors.lightGrayBorder),
          ),
          child: Row(
            children: [
              ProfilePhotoAvatar(
                photoUrl: user.photoUrl,
                displayName: user.nom,
                radius: 26,
              ),
              const SizedBox(width: SignmeSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nom,
                      style: SignmeTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          user.roleLabel,
                          style: SignmeTypography.bodySmall.copyWith(
                            color: SignmeColors.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (user.matricule != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '· ${user.matricule}',
                            style: SignmeTypography.bodySmall.copyWith(
                              color: SignmeColors.mediumGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (user.email.isNotEmpty)
                      Text(
                        user.email,
                        style: SignmeTypography.labelSmall.copyWith(
                          color: SignmeColors.mediumGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              _StatusBadge(actif: user.actif),
              const Icon(
                Icons.chevron_right_rounded,
                color: SignmeColors.mediumGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.actif});
  final bool actif;

  @override
  Widget build(BuildContext context) {
    final color = actif ? SignmeColors.success : SignmeColors.error;
    return Container(
      margin: const EdgeInsets.only(right: SignmeSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        actif ? 'Actif' : 'Inactif',
        style: SignmeTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
