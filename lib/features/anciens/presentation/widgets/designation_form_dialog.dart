import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';

class DesignationFormDialog extends StatefulWidget {
  const DesignationFormDialog({
    super.key,
    required this.ancienNom,
    this.onDesignate,
  });

  final String ancienNom;
  final Function(List<int>? jours, String? debut, String? fin)? onDesignate;

  @override
  State<DesignationFormDialog> createState() => _DesignationFormDialogState();
}

class _DesignationFormDialogState extends State<DesignationFormDialog> {
  // Jours sélectionnés (1-7)
  final Set<int> selectedDays = {};
  bool is24h = true; // Par défaut, 24/7
  
  String? timeStart = '00:00';
  String? timeEnd = '23:59';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SignmeColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(SignmeSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header
              Text(
                'Désigner ${widget.ancienNom}',
                style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Paramétrez sa disponibilité',
                style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.mediumGray),
              ),
              const SizedBox(height: SignmeSpacing.lg),

              // ── Section Jours ────────────────────────────────────────
              Text(
                '📅 Jours de service',
                style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SignmeSpacing.sm),

              // Option: 24/7
              CheckboxListTile(
                value: is24h,
                activeColor: SignmeColors.primaryLight,
                onChanged: (v) => setState(() {
                  is24h = v ?? false;
                  if (is24h) selectedDays.clear();
                }),
                title: Text(
                  'Tous les jours (24/7)',
                  style: SignmeTypography.bodyMedium,
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: SignmeSpacing.xs),

              // Jours spécifiques
              if (!is24h)
                Padding(
                  padding: const EdgeInsets.only(left: SignmeSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sélectionnez les jours:',
                        style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
                      ),
                      const SizedBox(height: SignmeSpacing.sm),
                      _buildDaysGrid(),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: SignmeSpacing.sm, top: 4, bottom: 4),
                  child: Text(
                    'L\'ancien peut servir tous les jours',
                    style: SignmeTypography.bodySmall.copyWith(
                      color: SignmeColors.mediumGray,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: SignmeSpacing.lg),

              // ── Section Horaires ──────────────────────────────────────
              Text(
                '⏰ Horaires',
                style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SignmeSpacing.sm),

              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(
                      label: 'Début',
                      value: timeStart,
                      onChanged: (v) => setState(() => timeStart = v),
                    ),
                  ),
                  const SizedBox(width: SignmeSpacing.md),
                  Expanded(
                    child: _buildTimeField(
                      label: 'Fin',
                      value: timeEnd,
                      onChanged: (v) => setState(() => timeEnd = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: SignmeSpacing.xs),
              Text(
                'Par défaut: 00:00 - 23:59',
                style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
              ),

              const SizedBox(height: SignmeSpacing.lg),

              // ── Resume
              Container(
                padding: const EdgeInsets.all(SignmeSpacing.md),
                decoration: BoxDecoration(
                  color: SignmeColors.accentSky.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                  border: Border.all(color: SignmeColors.primaryLight.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résumé:',
                      style: SignmeTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: SignmeColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSummary(),
                      style: SignmeTypography.bodySmall.copyWith(
                        color: SignmeColors.black,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: SignmeSpacing.xl),

              // ── Buttons
              Row(
                children: [
                  Expanded(
                    child: SignmeSecondaryButton(
                      label: 'Annuler',
                      onPressed: () => Navigator.pop(context),
                      height: 44,
                    ),
                  ),
                  const SizedBox(width: SignmeSpacing.md),
                  Expanded(
                    child: SignmePrimaryButton(
                      label: 'Désigner',
                      onPressed: _handleDesignate,
                      height: 44,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build days grid ───────────────────────────────────────────────────
  Widget _buildDaysGrid() {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (i) {
        final dayNum = i + 1;
        final isSelected = selectedDays.contains(dayNum);
        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected) {
              selectedDays.remove(dayNum);
            } else {
              selectedDays.add(dayNum);
            }
          }),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? SignmeColors.primaryLight : SignmeColors.white,
              border: Border.all(
                color: isSelected ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            ),
            child: Center(
              child: Text(
                days[i],
                style: SignmeTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? SignmeColors.white : SignmeColors.black,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Build time field ──────────────────────────────────────────────────
  Widget _buildTimeField({
    required String label,
    required String? value,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SignmeTypography.labelSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: SignmeColors.mediumGray,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _pickTime(context, value, onChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              border: Border.all(color: SignmeColors.lightGrayBorder),
              color: SignmeColors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? '--:--',
                  style: SignmeTypography.bodyMedium,
                ),
                const Icon(Icons.access_time_rounded, size: 18, color: SignmeColors.primaryLight),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Pick time ──────────────────────────────────────────────────────────
  Future<void> _pickTime(
    BuildContext context,
    String? currentTime,
    Function(String) onChanged,
  ) async {
    final now = DateTime.now();
    final time = await showTimePicker(
      context: context,
      initialTime: currentTime != null 
          ? TimeOfDay(hour: int.parse(currentTime.split(':')[0]), minute: int.parse(currentTime.split(':')[1]))
          : TimeOfDay.fromDateTime(now),
    );
    if (time != null) {
      final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      onChanged(formatted);
    }
  }

  // ── Build summary ──────────────────────────────────────────────────────
  String _buildSummary() {
    final jours = is24h
        ? 'Tous les jours'
        : selectedDays.isEmpty
            ? '❌ Aucun jour sélectionné'
            : _formatDays(selectedDays);

    return '• Jours: $jours\n• Horaires: $timeStart - $timeEnd';
  }

  String _formatDays(Set<int> days) {
    final labels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final sorted = days.toList()..sort();
    return sorted.map((d) => labels[d - 1]).join(', ');
  }

  // ── Handle designate ───────────────────────────────────────────────────
  void _handleDesignate() {
    if (!is24h && selectedDays.isEmpty) {
      AppSnackbar.error(context, 'Veuillez sélectionner au moins un jour');
      return;
    }

    widget.onDesignate?.call(
      is24h ? null : selectedDays.toList(),
      timeStart,
      timeEnd,
    );
    Navigator.pop(context);
  }
}
