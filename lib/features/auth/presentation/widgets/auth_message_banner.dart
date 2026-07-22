import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';

/// Bannière info / avertissement sur les écrans auth.
class AuthMessageBanner extends StatelessWidget {
  const AuthMessageBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? SignmeColors.warning.withOpacity(0.12);
    final fg = foregroundColor ?? SignmeColors.warning;

    return Container(
      width: double.infinity,
      padding: SignmeSpacing.symmMdMd,
      decoration:BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
        border: Border.all(color: fg.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: fg),
          SignmeSpacing.hGapSm,
          Expanded(
            child: Text(
              message,
              style: SignmeTypography.bodySmall.copyWith(
                color: SignmeColors.black,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
