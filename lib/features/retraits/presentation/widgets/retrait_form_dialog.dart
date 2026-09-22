import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/retrait_beneficiaire_entity.dart';
import '../providers/retrait_form_provider.dart';
import 'retrait_status_badge.dart';

enum _RetraitStep { montant, recap, resultat }

/// Flux d'initiation d'un retrait — TOUJOURS en 3 étapes : saisie du montant,
/// récapitulatif (numéro + montant) à confirmer explicitement, puis résultat
/// avec le statut exact renvoyé par le serveur. Aucune étape n'est
/// sautable : "toujours faire récapitulatif" est une exigence non négociable.
class RetraitFormDialog extends ConsumerStatefulWidget {
  const RetraitFormDialog({super.key, required this.solde, required this.beneficiaire, required this.montantMin});

  final int solde;
  final RetraitBeneficiaireEntity beneficiaire;
  final int montantMin;

  @override
  ConsumerState<RetraitFormDialog> createState() => _RetraitFormDialogState();
}

class _RetraitFormDialogState extends ConsumerState<RetraitFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montantCtrl = TextEditingController();
  _RetraitStep _step = _RetraitStep.montant;
  int _montant = 0;

  @override
  void dispose() {
    _montantCtrl.dispose();
    super.dispose();
  }

  void _goToRecap() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _montant = int.parse(_montantCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
      _step = _RetraitStep.recap;
    });
  }

  void _confirmer() {
    setState(() => _step = _RetraitStep.resultat);
    ref.read(retraitFormProvider.notifier).initier(_montant);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(retraitFormProvider);

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
          child: switch (_step) {
            _RetraitStep.montant => _buildMontantStep(),
            _RetraitStep.recap => _buildRecapStep(),
            _RetraitStep.resultat => _buildResultatStep(state),
          },
        ),
      ),
    );
  }

  Widget _buildMontantStep() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Retrait', style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: SignmeSpacing.sm),
          Text(
            'Solde disponible : ${FinanceFormatters.fcfa(widget.solde)}',
            style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.mediumGray),
          ),
          const SizedBox(height: SignmeSpacing.lg),
          SignmeTextInput(
            label: 'Montant à retirer (FCFA)',
            hint: 'Ex. 10000',
            controller: _montantCtrl,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Requis';
              final m = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
              if (m == null || m < widget.montantMin) {
                return 'Minimum ${FinanceFormatters.fcfa(widget.montantMin)}';
              }
              if (m > widget.solde) return 'Solde insuffisant';
              return null;
            },
          ),
          const SizedBox(height: SignmeSpacing.lg),
          Row(
            children: [
              Expanded(
                child: SignmeSecondaryButton(label: 'Annuler', onPressed: () => Navigator.pop(context)),
              ),
              const SizedBox(width: SignmeSpacing.md),
              Expanded(
                child: SignmePrimaryButton(label: 'Continuer', onPressed: _goToRecap),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecapStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Confirmer le retrait', style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: SignmeSpacing.sm),
        Text(
          'Vérifiez les informations avant de valider — cette action déclenche un transfert réel.',
          style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
        ),
        const SizedBox(height: SignmeSpacing.lg),
        Container(
          padding: const EdgeInsets.all(SignmeSpacing.md),
          decoration: BoxDecoration(
            color: SignmeColors.accentSky,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecapRow(label: 'Montant', value: FinanceFormatters.fcfa(_montant)),
              const SizedBox(height: SignmeSpacing.sm),
              _RecapRow(label: 'Destination', value: widget.beneficiaire.operator),
              const SizedBox(height: SignmeSpacing.sm),
              _RecapRow(label: 'Numéro', value: widget.beneficiaire.numeroMasque),
            ],
          ),
        ),
        const SizedBox(height: SignmeSpacing.lg),
        Row(
          children: [
            Expanded(
              child: SignmeSecondaryButton(
                label: 'Retour',
                onPressed: () => setState(() => _step = _RetraitStep.montant),
              ),
            ),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: SignmePrimaryButton(label: 'Confirmer le retrait', onPressed: _confirmer),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultatStep(RetraitFormState state) {
    if (state.isLoading) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator(color: SignmeColors.primaryLight)),
      );
    }

    if (state.error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.error_rounded, color: SignmeColors.error, size: 48),
          const SizedBox(height: SignmeSpacing.md),
          Text(
            state.error!,
            textAlign: TextAlign.center,
            style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.error),
          ),
          const SizedBox(height: SignmeSpacing.lg),
          SignmePrimaryButton(label: 'Fermer', onPressed: () => Navigator.pop(context, false)),
        ],
      );
    }

    final retrait = state.result!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Icon(
            retrait.isFailed ? Icons.error_rounded : Icons.check_circle_rounded,
            color: retrait.isFailed ? SignmeColors.error : SignmeColors.success,
            size: 56,
          ),
        ),
        const SizedBox(height: SignmeSpacing.md),
        Center(
          child: Text(
            retrait.isFailed ? 'Le retrait a échoué' : 'Retrait initié',
            style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: SignmeSpacing.sm),
        Center(child: RetraitStatusBadge(retrait: retrait)),
        const SizedBox(height: SignmeSpacing.lg),
        Container(
          padding: const EdgeInsets.all(SignmeSpacing.md),
          decoration: BoxDecoration(
            color: SignmeColors.accentSky,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecapRow(label: 'Montant demandé', value: FinanceFormatters.fcfa(retrait.montantDemande)),
              if (retrait.frais > 0) ...[
                const SizedBox(height: SignmeSpacing.sm),
                _RecapRow(label: 'Frais retenus', value: FinanceFormatters.fcfa(retrait.frais)),
                const SizedBox(height: SignmeSpacing.sm),
                _RecapRow(label: 'Montant reçu', value: FinanceFormatters.fcfa(retrait.montantNet)),
              ],
            ],
          ),
        ),
        if (retrait.isFailed && retrait.motifEchec != null) ...[
          const SizedBox(height: SignmeSpacing.md),
          Text(retrait.motifEchec!, style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error)),
        ],
        const SizedBox(height: SignmeSpacing.lg),
        SignmePrimaryButton(label: 'Terminé', onPressed: () => Navigator.pop(context, true)),
      ],
    );
  }
}

class _RecapRow extends StatelessWidget {
  const _RecapRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.mediumGray)),
        Text(value, style: SignmeTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
