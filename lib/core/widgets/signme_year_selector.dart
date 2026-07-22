import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// Sélecteur d'année (← 2026 →) réutilisable.
class SignmeYearSelector extends StatelessWidget {
  const SignmeYearSelector({
    super.key,
    required this.year,
    required this.onPrevious,
    required this.onNext,
    this.minYear,
    this.maxYear,
    this.label,
  });

  final int year;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final int? minYear;
  final int? maxYear;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final canGoBack = minYear == null || year > minYear!;
    final canGoForward = maxYear == null || year < maxYear!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SignmeSpacing.sm,
        vertical: SignmeSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [
          BoxShadow(
            color: SignmeColors.primaryDark.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavButton(
            icon: Icons.chevron_left_rounded,
            enabled: canGoBack,
            onTap: onPrevious,
          ),
          Expanded(
            child: Column(
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: SignmeTypography.labelSmall.copyWith(
                      color: SignmeColors.mediumGray,
                    ),
                  ),
                Text(
                  year.toString(),
                  style: SignmeTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: SignmeColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            enabled: canGoForward,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? SignmeColors.accentSky.withOpacity(0.5)
          : SignmeColors.lightGray,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: enabled ? SignmeColors.primaryLight : SignmeColors.mediumGray,
            size: 28,
          ),
        ),
      ),
    );
  }
}
