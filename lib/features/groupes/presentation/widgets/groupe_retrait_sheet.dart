import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/widgets/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../../retraits/domain/entities/retrait_beneficiaire_entity.dart';
import '../../../retraits/domain/entities/retrait_entity.dart';
import '../providers/groupes_provider.dart';
import 'groupe_sheet.dart';

/// Retrait de l'argent EN LIGNE de la caisse vers le Mobile Money du
/// président/trésorier. Toujours en étapes : compte de retrait (si absent),
/// montant + motif, récapitulatif à confirmer, résultat. Le motif est
/// obligatoire : il est visible de tous les membres du groupe.
Future<bool?> showGroupeRetraitSheet(
  BuildContext context, {
  required String groupeUuid,
  required int soldeEnLigne,
}) {
  return showSignmeSheet<bool>(
    context,
    title: 'Retirer de la caisse',
    builder: (_) => _RetraitFlow(groupeUuid: groupeUuid, soldeEnLigne: soldeEnLigne),
  );
}

enum _Step { compte, saisie, recap, resultat }

class _RetraitFlow extends ConsumerStatefulWidget {
  const _RetraitFlow({required this.groupeUuid, required this.soldeEnLigne});

  final String groupeUuid;
  final int soldeEnLigne;

  @override
  ConsumerState<_RetraitFlow> createState() => _RetraitFlowState();
}

class _RetraitFlowState extends ConsumerState<_RetraitFlow> {
  static const _montantMin = 1000;

  final _montant = TextEditingController();
  final _motif = TextEditingController();
  final _phone = TextEditingController();
  String _operator = 'ORANGE MONEY';

  _Step? _step; // null = chargement du compte de retrait
  RetraitBeneficiaireEntity? _beneficiaire;
  RetraitEntity? _retrait;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _montant.dispose();
    _motif.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    try {
      final b = await ref.read(mesGroupesRemoteDataSourceProvider).beneficiaire(widget.groupeUuid);
      if (!mounted) return;
      setState(() {
        _beneficiaire = b;
        _step = b == null ? _Step.compte : _Step.saisie;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = messageFromError(e);
        _step = _Step.compte;
      });
    }
  }

  int get _valeur => int.tryParse(_montant.text) ?? 0;

  bool get _saisieValide => _valeur >= _montantMin && _valeur <= widget.soldeEnLigne && _motif.text.trim().isNotEmpty;

  bool get _phoneValide => _phone.text.length == 9 && _phone.text.startsWith('6');

  Future<void> _enregistrerCompte() async {
    if (_busy || !_phoneValide) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final b = await ref
          .read(mesGroupesRemoteDataSourceProvider)
          .enregistrerBeneficiaire(widget.groupeUuid, operator: _operator, phone: _phone.text.trim());
      if (!mounted) return;
      setState(() {
        _beneficiaire = b;
        _busy = false;
        _step = _Step.saisie;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = messageFromError(e);
      });
    }
  }

  Future<void> _confirmer() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await ref
          .read(mesGroupesRemoteDataSourceProvider)
          .retirer(widget.groupeUuid, montant: _valeur, motif: _motif.text.trim());
      if (!mounted) return;
      setState(() {
        _retrait = r;
        _busy = false;
        _step = _Step.resultat;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = messageFromError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      null => const Padding(
          padding: EdgeInsets.all(SignmeSpacing.xxl),
          child: Center(child: CircularProgressIndicator(color: SignmeColors.primaryLight)),
        ),
      _Step.compte => _compte(),
      _Step.saisie => _saisie(),
      _Step.recap => _recap(),
      _Step.resultat => _resultat(),
    };
  }

  Widget _erreur() => _error == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: SignmeSpacing.md),
          child: Text(_error!, style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error)),
        );

  Widget _compte() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enregistrez le compte Mobile Money qui recevra les retraits.',
          style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.darkGray),
        ),
        const SizedBox(height: SignmeSpacing.lg),
        Row(
          children: [
            for (final (valeur, label) in const [('ORANGE MONEY', 'Orange Money'), ('MTN MOBILE MONEY', 'MTN Money')]) ...[
              Expanded(
                child: _Choix(label: label, selected: _operator == valeur, onTap: () => setState(() => _operator = valeur)),
              ),
              if (valeur == 'ORANGE MONEY') const SizedBox(width: SignmeSpacing.md),
            ],
          ],
        ),
        const SizedBox(height: SignmeSpacing.md),
        GroupeField(
          controller: _phone,
          hint: 'Numéro (9 chiffres)',
          icon: Icons.smartphone_rounded,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
          onChanged: (_) => setState(() {}),
        ),
        _erreur(),
        const SizedBox(height: SignmeSpacing.lg),
        SignmePrimaryButton(label: 'Enregistrer ce compte', enabled: _phoneValide, isLoading: _busy, onPressed: _enregistrerCompte),
      ],
    );
  }

  Widget _saisie() {
    final b = _beneficiaire!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Bandeau(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Disponible en ligne',
          value: FinanceFormatters.fcfa(widget.soldeEnLigne),
        ),
        const SizedBox(height: SignmeSpacing.md),
        _Bandeau(icon: Icons.smartphone_rounded, label: b.operator, value: b.numeroMasque),
        const SizedBox(height: SignmeSpacing.lg),
        GroupeField(
          controller: _montant,
          hint: 'Montant à retirer',
          icon: Icons.payments_outlined,
          suffixText: 'FCFA',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textStyle: SignmeTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
          onChanged: (_) => setState(() {}),
        ),
        if (_valeur > widget.soldeEnLigne)
          Padding(
            padding: const EdgeInsets.only(top: SignmeSpacing.sm),
            child: Text('Montant supérieur au solde disponible.', style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error)),
          )
        else if (_montant.text.isNotEmpty && _valeur < _montantMin)
          Padding(
            padding: const EdgeInsets.only(top: SignmeSpacing.sm),
            child: Text('Minimum ${FinanceFormatters.fcfa(_montantMin)}.', style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error)),
          ),
        const SizedBox(height: SignmeSpacing.md),
        GroupeField(
          controller: _motif,
          hint: 'Motif (visible de tous les membres)',
          icon: Icons.edit_note_rounded,
          maxLines: 2,
          maxLength: 255,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: SignmeSpacing.lg),
        SignmePrimaryButton(label: 'Continuer', enabled: _saisieValide, onPressed: () => setState(() => _step = _Step.recap)),
      ],
    );
  }

  Widget _recap() {
    final b = _beneficiaire!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vérifiez avant de confirmer', style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.darkGray)),
        const SizedBox(height: SignmeSpacing.md),
        Container(
          padding: const EdgeInsets.all(SignmeSpacing.lg),
          decoration: BoxDecoration(
            color: SignmeColors.accentSky,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            border: Border.all(color: SignmeColors.primaryLight.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              _Ligne('Montant', FinanceFormatters.fcfa(_valeur)),
              const SizedBox(height: SignmeSpacing.sm),
              _Ligne('Vers', '${b.operator} · ${b.numeroMasque}'),
              const SizedBox(height: SignmeSpacing.sm),
              _Ligne('Motif', _motif.text.trim()),
            ],
          ),
        ),
        _erreur(),
        const SizedBox(height: SignmeSpacing.lg),
        SignmePrimaryButton(label: 'Confirmer le retrait', icon: Icons.check_rounded, isLoading: _busy, onPressed: _confirmer),
        const SizedBox(height: SignmeSpacing.sm),
        SignmeSecondaryButton(label: 'Modifier', onPressed: _busy ? null : () => setState(() => _step = _Step.saisie)),
      ],
    );
  }

  Widget _resultat() {
    final r = _retrait!;
    final echec = r.isFailed;
    return Column(
      children: [
        Icon(
          echec ? Icons.error_outline_rounded : Icons.check_circle_rounded,
          size: 64,
          color: echec ? SignmeColors.error : SignmeColors.success,
        ),
        const SizedBox(height: SignmeSpacing.md),
        Text(
          echec ? 'Retrait échoué' : r.isCompleted ? 'Retrait effectué' : 'Retrait en cours',
          style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: SignmeSpacing.sm),
        Text(
          echec
              ? (r.motifEchec ?? 'Le retrait n\'a pas pu être effectué. Aucun montant n\'a été débité.')
              : '${FinanceFormatters.fcfa(r.montantNet)} seront reçus sur votre compte (frais : ${FinanceFormatters.fcfa(r.frais)}).',
          textAlign: TextAlign.center,
          style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.darkGray, height: 1.4),
        ),
        const SizedBox(height: SignmeSpacing.lg),
        SignmePrimaryButton(label: 'Fermer', onPressed: () => Navigator.pop(context, true)),
      ],
    );
  }
}

class _Bandeau extends StatelessWidget {
  const _Bandeau({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg, vertical: SignmeSpacing.md),
      decoration: BoxDecoration(
        color: SignmeColors.accentSky,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.primaryLight.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: SignmeColors.primaryLight),
          const SizedBox(width: SignmeSpacing.md),
          Expanded(child: Text(label, style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.darkGray))),
          Text(value, style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, color: SignmeColors.primaryLight)),
        ],
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 64, child: Text(label, style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.darkGray))),
        Expanded(child: Text(value, style: SignmeTypography.labelMedium.copyWith(fontWeight: FontWeight.w700))),
      ],
    );
  }
}

class _Choix extends StatelessWidget {
  const _Choix({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: SignmeSpacing.animationFast,
          padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? SignmeColors.primaryLight.withValues(alpha: 0.08) : SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            border: Border.all(
              color: selected ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: SignmeTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: selected ? SignmeColors.primaryLight : SignmeColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
