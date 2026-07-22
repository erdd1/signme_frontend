import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';

class UserInfo extends ConsumerWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final UserEntity? user = authState.auth?.user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes Informations',
          style: SignmeTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: SignmeColors.black,
          ),
        ),
        const SizedBox(height: SignmeSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            border: Border.all(color: SignmeColors.lightGrayBorder),
          ),
          child: Column(
            children: [
              _buildUserTile(
                icon: Icons.person_outline,
                title: 'Nom',
                subtitle: user.nom,
              ),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              _buildUserTile(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: user.email,
              ),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              _buildUserTile(
                icon: Icons.badge_outlined,
                title: 'Rôle',
                subtitle: _formatRole(user.role),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SignmeSpacing.lg,
        vertical: SignmeSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SignmeSpacing.sm),
            decoration: BoxDecoration(
              color: SignmeColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            ),
            child: Icon(icon, color: SignmeColors.primaryLight, size: 20),
          ),
          const SizedBox(width: SignmeSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SignmeTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: SignmeColors.mediumGray,
                  ),
                ),
                const SizedBox(height: SignmeSpacing.xs),
                Text(
                  subtitle,
                  style: SignmeTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: SignmeColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRole(String role) {
    const roleMap = {
      'pasteur': 'Pasteur',
      'ancien': 'Ancien',
      'secretaire': 'Secrétaire',
      'tresorier': 'Trésorier',
      'membre': 'Membre',
    };
    return roleMap[role.toLowerCase()] ?? role;
  }
}
