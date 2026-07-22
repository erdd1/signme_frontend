import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// SIGNME DATE PICKER FIELD - Standard Production Component
/// Champ de saisie de date thémé, ouvrant [showDatePicker] au tap. Même
/// style visuel que [SignmeTextInput] (fond accentSky, coins arrondis).
class SignmeDatePickerField extends FormField<DateTime> {
  SignmeDatePickerField({
    super.key,
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    String hint = 'JJ/MM/AAAA',
    DateTime? firstDate,
    DateTime? lastDate,
    bool enabled = true,
    super.validator,
  }) : super(
          initialValue: value,
          builder: (state) {
            final effectiveLastDate = lastDate ?? DateTime.now();
            final effectiveFirstDate = firstDate ?? DateTime(1900);

            Future<void> pickDate(BuildContext context) async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.value ?? effectiveLastDate,
                firstDate: effectiveFirstDate,
                lastDate: effectiveLastDate,
                helpText: label,
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: SignmeColors.primaryLight,
                        ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                state.didChange(picked);
                onChanged(picked);
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
                  child: Text(
                    label,
                    style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                  onTap: enabled ? () => pickDate(state.context) : null,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: SignmeTypography.placeholder,
                      errorText: state.errorText,
                      suffixIcon: const Icon(
                        Icons.calendar_today_rounded,
                        color: SignmeColors.primaryLight,
                        size: 18,
                      ),
                      filled: true,
                      fillColor: SignmeColors.accentSky.withOpacity(0.25),
                      contentPadding: SignmeSpacing.inputPadding,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    child: Text(
                      state.value != null
                          ? '${state.value!.day.toString().padLeft(2, '0')}/'
                              '${state.value!.month.toString().padLeft(2, '0')}/'
                              '${state.value!.year}'
                          : hint,
                      style: state.value != null
                          ? SignmeTypography.bodyMedium
                          : SignmeTypography.placeholder,
                    ),
                  ),
                ),
              ],
            );
          },
        );
}
