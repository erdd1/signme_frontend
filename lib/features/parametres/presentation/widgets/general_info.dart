import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';

class GeneralInfo extends StatelessWidget {
  const GeneralInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Général',
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
              _buildSettingTile(
                icon: Icons.language_outlined,
                title: 'Langue',
                subtitle: 'Français',
              ),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              _buildSettingTile(
                icon: Icons.palette_outlined,
                title: 'Thème',
                subtitle: 'Clair',
              ),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              _buildSettingTile(
                icon: Icons.lock_outline,
                title: 'Sécurité',
                subtitle: 'Mot de passe',
              ),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              _buildSettingTile(
                icon: Icons.public_outlined,
                title: 'Région',
                subtitle: 'Cameroun',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
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
                    color: SignmeColors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: SignmeTypography.bodySmall.copyWith(
                    color: SignmeColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
