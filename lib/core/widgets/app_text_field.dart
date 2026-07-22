import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// SIGNME TEXT INPUT - Standard Production Component
/// professional text field with label and icon support.
class SignmeTextInput extends StatefulWidget {
  const SignmeTextInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.leadingIcon,
    this.trailingIcon,
    this.onTrailingTap,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.autofillHints,
    this.focusNode,
    this.errorText,
    this.helperText,
    this.isLoading = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final String? errorText;
  final String? helperText;
  final bool isLoading;

  @override
  State<SignmeTextInput> createState() => _SignmeTextInputState();
}

class _SignmeTextInputState extends State<SignmeTextInput> {
  bool _obscure = true;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _validationError = widget.errorText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
          child: Text(
            widget.label,
            style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.isPassword ? _obscure : false,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          onChanged: (value) {
            if (_validationError != null) {
              setState(() => _validationError = null);
            }
            widget.onChanged?.call(value);
          },
          enabled: widget.enabled && !widget.isLoading,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          autofillHints: widget.autofillHints,
          style: SignmeTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: SignmeTypography.placeholder,
            helperText: widget.helperText,
            errorText: _validationError,
            prefixIcon: widget.leadingIcon != null
                ? Icon(widget.leadingIcon, color: SignmeColors.primaryLight, size: 20)
                : null,
            suffixIcon: widget.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : (widget.isPassword
                    ? IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: SignmeColors.mediumGray, size: 20),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )
                    : (widget.trailingIcon != null
                        ? IconButton(
                            icon: Icon(widget.trailingIcon, color: SignmeColors.mediumGray, size: 20),
                            onPressed: widget.onTrailingTap,
                          )
                        : null)),
            filled: true,
            fillColor: SignmeColors.accentSky.withOpacity(0.2),
            contentPadding: SignmeSpacing.inputPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              borderSide: const BorderSide(color: SignmeColors.primaryLight, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
