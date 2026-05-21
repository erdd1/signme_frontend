import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Champ de texte EEC SignCard avec label au-dessus et icône
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.leadingIcon,
    this.trailingIcon,
    this.onTrailingTap,
    this.isPassword     = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
    this.onChanged,
    this.enabled        = true,
    this.maxLines       = 1,
    this.maxLength,
    this.autofillHints,
    this.focusNode,
  });

  final String                label;
  final String                hint;
  final TextEditingController controller;
  final IconData?             leadingIcon;
  final IconData?             trailingIcon;
  final VoidCallback?         onTrailingTap;
  final bool                  isPassword;
  final TextInputType?        keyboardType;
  final TextInputAction?      textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool                  enabled;
  final int                   maxLines;
  final int?                  maxLength;
  final Iterable<String>?     autofillHints;
  final FocusNode?            focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ───────────────────────────────────────
        Text(
          widget.label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        // ── Field ───────────────────────────────────────
        TextFormField(
          controller:       widget.controller,
          focusNode:        widget.focusNode,
          obscureText:      widget.isPassword ? _obscure : false,
          keyboardType:     widget.keyboardType,
          textInputAction:  widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          validator:        widget.validator,
          onChanged:        widget.onChanged,
          enabled:          widget.enabled,
          maxLines:         widget.isPassword ? 1 : widget.maxLines,
          maxLength:        widget.maxLength,
          autofillHints:    widget.autofillHints,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textHint,
              fontSize: 14,
            ),
            prefixIcon: widget.leadingIcon != null
                ? Icon(widget.leadingIcon, color: AppColors.textSecondary, size: 20)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : (widget.trailingIcon != null
                    ? IconButton(
                        icon: Icon(widget.trailingIcon, color: AppColors.textSecondary, size: 20),
                        onPressed: widget.onTrailingTap,
                      )
                    : null),
            filled:    true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.textFieldRadius),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
