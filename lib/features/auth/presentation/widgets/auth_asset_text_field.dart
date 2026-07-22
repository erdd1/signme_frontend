import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';

/// Champ texte auth avec icône asset dans un cercle bleu clair.
class AuthAssetTextField extends StatelessWidget {
  const AuthAssetTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.assetPath,
    this.keyboardType,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleObscure,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.textInputAction,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String assetPath;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextInputAction? textInputAction;

  static const double _radius = SignmeSpacing.radiusLg; // 16 px
  static const double _circleSize = 36.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SignmeTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: SignmeColors.onSurface,
          ),
        ),
        const SizedBox(height: SignmeSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? obscureText : false,
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
          textInputAction: textInputAction,
          style: SignmeTypography.bodyLarge.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: SignmeTypography.bodyMedium.copyWith(
              color: SignmeColors.mediumGray,
              fontSize: 14,
            ),

            // ── Icône dans cercle bleu clair ──────────────────────────
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SignmeSpacing.md,
              ),
              child: Container(
                width: _circleSize,
                height: _circleSize,
                decoration: const BoxDecoration(
                  color: SignmeColors.accentSky,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    assetPath,
                    width: 18,
                    height: 18,
                    color: SignmeColors.primaryLight, // icône bleue
                  ),
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 64,
              minHeight: SignmeSpacing.textFieldHeight,
            ),

            // ── Toggle visibilité mot de passe ────────────────────────
            suffixIcon: isPassword && onToggleObscure != null
                ? IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: SignmeColors.mediumGray,
                size: 20,
              ),
              onPressed: onToggleObscure,
            )
                : null,

            filled: true,
            fillColor: SignmeColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SignmeSpacing.lg,
              vertical: 18,
            ),

            // ── Bordures ──────────────────────────────────────────────
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: const BorderSide(
                color: SignmeColors.lightGrayBorder,
                width: SignmeSpacing.borderThin,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: const BorderSide(
                color: SignmeColors.lightGrayBorder,
                width: SignmeSpacing.borderThin,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: const BorderSide(
                color: SignmeColors.primaryLight,
                width: SignmeSpacing.borderMedium,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: const BorderSide(
                color: SignmeColors.error,
                width: SignmeSpacing.borderThin,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: const BorderSide(
                color: SignmeColors.error,
                width: SignmeSpacing.borderMedium,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: const BorderSide(
                color: SignmeColors.lightGrayBorder,
                width: SignmeSpacing.borderThin,
              ),
            ),
          ),
        ),
      ],
    );
  }
}