import 'package:flutter/material.dart';
import '../../../features/auth/domain/entities/user_entity.dart';
import '../design_system/index.dart';

class UserInfoCard extends StatelessWidget {
  final UserEntity user;

  const UserInfoCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
        decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom
          _buildInfoRow(
            label: 'Nom',
            value: user.nom,
          ),
          const SizedBox(height: SignmeSpacing.lg),

          // Email
          _buildInfoRow(
            label: 'Email',
            value: user.email,
          ),
          const SizedBox(height: SignmeSpacing.lg),

          // Rôle
          _buildInfoRow(
            label: 'Rôle',
            value: _formatRole(user.role),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SignmeTypography.labelSmall.copyWith(
            color: SignmeColors.mediumGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SignmeSpacing.sm),
        Text(
          value,
          style: SignmeTypography.bodyMedium.copyWith(
            color: SignmeColors.black,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
