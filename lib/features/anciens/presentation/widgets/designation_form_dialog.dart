import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

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
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header
              Text(
                'Désigner ${widget.ancienNom}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Paramétrez sa disponibilité',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // ── Section Jours ────────────────────────────────────────
              Text(
                '📅 Jours de service',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Option: 24/7
              CheckboxListTile(
                value: is24h,
                onChanged: (v) => setState(() {
                  is24h = v ?? false;
                  if (is24h) selectedDays.clear();
                }),
                title: Text(
                  'Tous les jours (24/7)',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 8),

              // Jours spécifiques
              if (!is24h)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    children: [
                      Text(
                        'Sélectionnez les jours:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDaysGrid(),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                  child: Text(
                    'L\'ancien peut servir tous les jours',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textHint,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ── Section Horaires ──────────────────────────────────────
              Text(
                '⏰ Horaires',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(
                      label: 'Début',
                      value: timeStart,
                      onChanged: (v) => setState(() => timeStart = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeField(
                      label: 'Fin',
                      value: timeEnd,
                      onChanged: (v) => setState(() => timeEnd = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                'Par défaut: 00:00 - 23:59',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),

              const SizedBox(height: 24),

              // ── Resume
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résumé:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSummary(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Annuler',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleDesignate,
                      child: Text(
                        'Désigner',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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
              color: isSelected ? AppColors.primary : AppColors.background,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                days[i],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
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
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          readOnly: true,
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onTap: () => _pickTime(context, value, onChanged),
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
      initialTime: TimeOfDay.fromDateTime(now),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins un jour')),
      );
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
