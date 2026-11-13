import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/index.dart';

// ============================================================================
// SIGNME BUTTON COMPONENTS (Standard Production)
// ============================================================================

/// PRIMARY BUTTON - Main action button with gradient background
class SignmePrimaryButton extends StatelessWidget {
  const SignmePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.width,
    this.height = SignmeSpacing.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(colors: SignmeColors.buttonGradient)
            : LinearGradient(
                colors: [SignmeColors.disabled, SignmeColors.disabled],
              ),
        borderRadius: BorderRadius.circular(SignmeSpacing.buttonBorderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (enabled && !isLoading)
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed?.call();
                }
              : null,
          borderRadius: BorderRadius.circular(SignmeSpacing.buttonBorderRadius),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(SignmeColors.onPrimary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: SignmeSpacing.iconMd, color: SignmeColors.onPrimary),
                        const SizedBox(width: SignmeSpacing.sm),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          style: SignmeTypography.buttonText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// SECONDARY BUTTON - Outlined button with accent color
class SignmeSecondaryButton extends StatelessWidget {
  const SignmeSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
    this.width,
    this.height = SignmeSpacing.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? SignmeColors.primary;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor, width: SignmeSpacing.borderMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SignmeSpacing.buttonBorderRadius),
          ),
          padding: SignmeSpacing.buttonPadding,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(buttonColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: SignmeSpacing.iconMd),
                    const SizedBox(width: SignmeSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: SignmeTypography.titleLarge.copyWith(color: buttonColor, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// TEXT BUTTON - Minimal text-only button
class SignmeTextButton extends StatelessWidget {
  const SignmeTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.fontSize = 14,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final double fontSize;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? SignmeColors.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SignmeSpacing.sm,
            vertical: SignmeSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: SignmeSpacing.iconSm, color: textColor),
                const SizedBox(width: SignmeSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  style: SignmeTypography.titleMedium.copyWith(color: textColor, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
