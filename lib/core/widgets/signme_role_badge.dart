import 'package:flutter/material.dart';
import '../design_system/index.dart';
import '../permissions/app_permissions.dart';

/// Badge de rôle aligné sur le design system SignMe.
class SignmeRoleBadge extends StatelessWidget {
  const SignmeRoleBadge({
    super.key,
    required this.role,
    this.compact = false,
  });

  final String role;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SignmeColors.primaryLight.withOpacity(0.15),
            SignmeColors.primaryCyan.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(
          color: SignmeColors.primaryLight.withOpacity(0.35),
        ),
      ),
      child: Text(
        AppPermissions.roleLabel(role),
        style: SignmeTypography.labelSmall.copyWith(
          color: SignmeColors.primaryDark,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 10 : 11,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
