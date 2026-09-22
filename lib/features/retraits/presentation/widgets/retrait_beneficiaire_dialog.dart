import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/entities/retrait_beneficiaire_entity.dart';
import '../providers/retrait_beneficiaire_form_provider.dart';

/// Enregistrement (ou remplacement) du compte de retrait Orange Money/MTN
/// Mobile Money — appelé une seule fois, modifiable ensuite depuis le même
/// dialog. Toujours affiché AVANT le premier retrait (voir RetraitScreen).
class RetraitBeneficiaireDialog extends ConsumerStatefulWidget {
  const RetraitBeneficiaireDialog({super.key, this.beneficiaireActuel});

  final RetraitBeneficiaireEntity? beneficiaireActuel;

  @override
  ConsumerState<RetraitBeneficiaireDialog> createState() => _RetraitBeneficiaireDialogState();
}

class _RetraitBeneficiaireDialogState extends ConsumerState<RetraitBeneficiaireDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  String _operator = 'ORANGE MONEY';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(retraitBeneficiaireFormProvider.notifier).enregistrer(
          operator: _operator,
          phone: _phoneCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(retraitBeneficiaireFormProvider);

    ref.listen(retraitBeneficiaireFormProvider, (previous, next) {
      if (next.success && context.mounted) {
        Navigator.pop(context, true);
      }
    });

    final isReplacement = widget.beneficiaireActuel != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
      backgroundColor: SignmeColors.white,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: SignmeSpacing.lg,
            right: SignmeSpacing.lg,
            top: SignmeSpacing.lg,
            bottom: SignmeSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
          ),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isReplacement ? 'Modifier le compte de retrait' : 'Compte de retrait',
                  style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: SignmeSpacing.sm),
                Text(
                  'C\'est le numéro qui recevra vos retraits. '
                  '${isReplacement ? "L'ancien compte sera remplacé." : ""}',
                  style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
                ),
                const SizedBox(height: SignmeSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _OperatorChoiceChip(
                        label: 'Orange Money',
                        selected: _operator == 'ORANGE MONEY',
                        onTap: () => setState(() => _operator = 'ORANGE MONEY'),
                      ),
                    ),
                    const SizedBox(width: SignmeSpacing.sm),
                    Expanded(
                      child: _OperatorChoiceChip(
                        label: 'MTN Mobile Money',
                        selected: _operator == 'MTN MOBILE MONEY',
                        onTap: () => setState(() => _operator = 'MTN MOBILE MONEY'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SignmeSpacing.md),
                SignmeTextInput(
                  label: 'Numéro de téléphone',
                  hint: 'Ex. 699112233',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  enabled: !state.isLoading,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requis';
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 9) return 'Numéro invalide';
                    return null;
                  },
                ),
                const SizedBox(height: SignmeSpacing.lg),
                if (state.error != null) ...[
                  Text(state.error!, style: const TextStyle(color: SignmeColors.error)),
                  const SizedBox(height: SignmeSpacing.sm),
                ],
                Row(
                  children: [
                    Expanded(
                      child: SignmeSecondaryButton(
                        label: 'Annuler',
                        onPressed: state.isLoading ? null : () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: SignmeSpacing.md),
                    Expanded(
                      child: SignmePrimaryButton(
                        label: 'Enregistrer',
                        isLoading: state.isLoading,
                        onPressed: state.isLoading ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OperatorChoiceChip extends StatelessWidget {
  const _OperatorChoiceChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? SignmeColors.primaryLight : SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          border: Border.all(color: selected ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: SignmeTypography.labelMedium.copyWith(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : SignmeColors.black,
          ),
        ),
      ),
    );
  }
}
