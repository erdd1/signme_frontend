import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/index.dart';

/// Ouvre une feuille modale au gabarit commun du service Groupes : poignée,
/// titre, contenu défilant qui remonte au-dessus du clavier.
Future<T?> showGroupeSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.9),
        decoration: const BoxDecoration(
          color: SignmeColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(SignmeSpacing.radiusXl)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            SignmeSpacing.lg,
            SignmeSpacing.md,
            SignmeSpacing.lg,
            MediaQuery.of(sheetContext).padding.bottom + SignmeSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: SignmeSpacing.lg),
                  decoration: BoxDecoration(
                    color: SignmeColors.lightGrayBorder,
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
                  ),
                ),
              ),
              Text(title, style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle, style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray)),
              ],
              const SizedBox(height: SignmeSpacing.lg),
              builder(sheetContext),
            ],
          ),
        ),
      ),
    ),
  );
}

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
