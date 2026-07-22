import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'À propos',
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
              _buildInfoTile(
                icon: Icons.apps_outlined,
                title: 'Nom de l\'app',
                subtitle: 'SignMe',
              ),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              _buildInfoTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '1.0.0',
              ),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              _buildInfoTile(
                icon: Icons.build_outlined,
                title: 'Build',
                subtitle: '1',
              ),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              _buildInfoTile(
                icon: Icons.people_outline,
                title: 'Développé par',
                subtitle: 'SignMe Team',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
