import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/index.dart';

/// Champ de saisie au style des formulaires premium (carte blanche, ombre douce).
class GroupeField extends StatelessWidget {
  const GroupeField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.suffixText,
    this.onChanged,
    this.textStyle,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? maxLength;
  final String? suffixText;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        style: textStyle ?? SignmeTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: SignmeTypography.placeholder,
          counterText: '',
          suffixText: suffixText,
          prefixIcon: icon == null
              ? null
              : Container(
                  margin: const EdgeInsets.all(SignmeSpacing.sm),
                  padding: const EdgeInsets.all(SignmeSpacing.sm),
                  decoration: BoxDecoration(
                    color: SignmeColors.accentSky,
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
                  ),
                  child: Icon(icon, color: SignmeColors.primaryLight, size: 18),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: SignmeSpacing.lg, horizontal: SignmeSpacing.md),
        ),
      ),
    );
  }
}
