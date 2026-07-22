import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/payments/card_checkout_webview_screen.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/evenement_entity.dart';
import '../providers/contribution_form_provider.dart';

/// Formulaire de contribution à un événement + suivi du paiement NotchPay.
class ContributionFormScreen extends ConsumerStatefulWidget {
  const ContributionFormScreen({super.key, required this.evenement});

  final EvenementEntity evenement;

  @override
  ConsumerState<ContributionFormScreen> createState() => _ContributionFormScreenState();
}

class _ContributionFormScreenState extends ConsumerState<ContributionFormScreen> {
  final _montantCtrl = TextEditingController(text: '500');
  final _noteCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(formDirtyProvider.notifier).state = false;
    });
    for (final controller in [_montantCtrl, _noteCtrl, _phoneCtrl]) {
      controller.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    _noteCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  /// Point d'écriture unique du drapeau global — appelé par tout champ
  /// modifié par l'utilisateur (montant, note, téléphone, groupe, opérateur,
  /// méthode de paiement).
  void _markDirty() {
    if (!ref.read(formDirtyProvider)) {
      ref.read(formDirtyProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contributionFormProvider);
    final groupes = ref.watch(authNotifierProvider).auth?.user.groupes ?? const <GroupeRef>[];

    return SignmeUnsavedChangesGuard(
      child: Scaffold(
        backgroundColor: SignmeColors.background,
        appBar: AppBar(
          backgroundColor: SignmeColors.white,
          elevation: 0,
          title: Text(
            'Contribution',
            style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          iconTheme: const IconThemeData(color: SignmeColors.black),
        ),
        body: state.paymentStatus == 'idle' ? _buildForm(state, groupes) : _buildPaymentStatus(state),
      ),
    );
  }

  Future<void> _submitPaiement(bool requiresGroupeSelection) async {
    final notifier = ref.read(contributionFormProvider.notifier);
    await notifier.effectuerPaiement(
      widget.evenement.uuid,
      requiresGroupeSelection: requiresGroupeSelection,
    );

    final authorizationUrl = ref.read(contributionFormProvider).authorizationUrl;
    if (authorizationUrl != null && authorizationUrl.isNotEmpty && mounted) {
      await CardCheckoutWebViewScreen.open(context, authorizationUrl);
      if (!mounted) return;
      await notifier.pollAfterCardCheckout();
    }
  }

  Widget _buildForm(ContributionFormState state, List<GroupeRef> groupes) {
    final frais = state.frais;
    final total = state.total;
    final requiresGroupeSelection = groupes.length > 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          SignmeSpacing.lg, SignmeSpacing.lg, SignmeSpacing.lg, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contribution à l\'événement',
            style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
          ),
          const SizedBox(height: 2),
          Text(
            widget.evenement.titre,
            style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
          ),
          if (widget.evenement.church.nom != null) ...[
            const SizedBox(height: 2),
            Text(
              widget.evenement.church.nom!,
              style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
            ),
          ],
          const SizedBox(height: SignmeSpacing.xl),

          if (groupes.length > 1) ...[
            SignmeCompactDropdown<GroupeRef>(
              label: 'Votre groupe',
              hint: 'Sélectionner votre groupe',
              value: groupes.any((g) => g.id == state.selectedGroupeId)
                  ? groupes.firstWhere((g) => g.id == state.selectedGroupeId)
                  : null,
              items: groupes,
              itemLabel: (g) => g.nom,
              onChanged: (g) {
                _markDirty();
                ref.read(contributionFormProvider.notifier).setGroupe(g?.id);
              },
            ),
            const SizedBox(height: SignmeSpacing.xl),
          ] else if (groupes.length == 1) ...[
            _sectionTitle('Votre groupe'),
            const SizedBox(height: SignmeSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg, vertical: SignmeSpacing.md),
              decoration: BoxDecoration(
                color: SignmeColors.accentSky.withOpacity(0.25),
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.groups_rounded, size: 18, color: SignmeColors.primaryLight),
                  const SizedBox(width: SignmeSpacing.sm),
                  Text(groupes.first.nom, style: SignmeTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: SignmeSpacing.xl),
          ],

          _sectionTitle('Montant de la contribution (FCFA)'),
          _montantField(),
          const SizedBox(height: SignmeSpacing.md),
          _feeDisplay(frais, total),

          const SizedBox(height: SignmeSpacing.xl),
          _sectionTitle('Note (optionnelle)'),
          _noteField(state),

          const SizedBox(height: SignmeSpacing.xl),
          _sectionTitle('Méthode de paiement'),
          const SizedBox(height: SignmeSpacing.sm),
          PaymentMethodSelector(
            selected: state.paymentMethod,
            onChanged: (m) {
              _markDirty();
              ref.read(contributionFormProvider.notifier).setPaymentMethod(m);
            },
          ),

          if (state.paymentMethod == 'mobile_money') ...[
            const SizedBox(height: SignmeSpacing.xl),
            _sectionTitle('Opérateur'),
            const SizedBox(height: SignmeSpacing.sm),
            _operatorRow(state),

            const SizedBox(height: SignmeSpacing.xl),
            _sectionTitle('Numéro de paiement'),
            const SizedBox(height: SignmeSpacing.sm),
            _phoneField(state),
          ],

          const SizedBox(height: SignmeSpacing.xl),
          if (total != null) _summary(total),
          const SizedBox(height: SignmeSpacing.lg),

          SignmePrimaryButton(
            label: 'Effectuer le paiement',
            enabled: frais != null &&
                (state.paymentMethod == 'card' || state.phone.length == 9) &&
                (!requiresGroupeSelection || state.selectedGroupeId != null),
            isLoading: state.isLoading,
            icon: Icons.volunteer_activism_rounded,
            onPressed: () => _submitPaiement(requiresGroupeSelection),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                state.error!,
                style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _montantField() {
    return Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: _montantCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (v) {
          final montant = int.tryParse(v) ?? 0;
          ref.read(contributionFormProvider.notifier).setMontant(montant);
        },
        style: SignmeTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: 'Ex: 700',
          prefixIcon: Container(
            margin: const EdgeInsets.all(SignmeSpacing.sm),
            padding: const EdgeInsets.all(SignmeSpacing.sm),
            decoration: BoxDecoration(
              color: SignmeColors.accentSky,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
            ),
            child: const Icon(Icons.payments_outlined, color: SignmeColors.primaryLight, size: 18),
          ),
          suffixText: 'FCFA',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
              vertical: SignmeSpacing.lg, horizontal: SignmeSpacing.sm),
        ),
      ),
    );
  }

  Widget _feeDisplay(int? frais, int? total) {
    final invalide = frais == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg, vertical: SignmeSpacing.md),
      decoration: BoxDecoration(
        color: invalide ? SignmeColors.error.withOpacity(0.06) : SignmeColors.accentSky,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(
          color: invalide
              ? SignmeColors.error.withOpacity(0.3)
              : SignmeColors.primaryLight.withOpacity(0.15),
        ),
      ),
      child: invalide
          ? Text(
              'Montant invalide : entre 500 et 1 000 000 FCFA, par multiples de 50.',
              style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error),
            )
          : Row(
              children: [
                Expanded(
                  child: _feeColumn('Contribution', FinanceFormatters.fcfaShort(_montantCtrl.text.isEmpty ? 0 : int.parse(_montantCtrl.text))),
                ),
                Expanded(child: _feeColumn('Frais', FinanceFormatters.fcfaShort(frais))),
                Expanded(child: _feeColumn('Total', FinanceFormatters.fcfaShort(total ?? 0), highlight: true)),
              ],
            ),
    );
  }

  Widget _feeColumn(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.darkGray)),
        const SizedBox(height: 2),
        Text(
          value,
          style: SignmeTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: highlight ? SignmeColors.primaryLight : SignmeColors.black,
          ),
        ),
      ],
    );
  }

  Widget _noteField(ContributionFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            border: Border.all(color: SignmeColors.lightGrayBorder),
          ),
          child: TextFormField(
            controller: _noteCtrl,
            maxLength: 100,
            maxLines: 2,
            onChanged: (v) => ref.read(contributionFormProvider.notifier).setNote(v),
            style: SignmeTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Ex: Pour la gloire de Dieu',
              hintStyle: SignmeTypography.placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
                borderSide: BorderSide.none,
              ),
              counterText: '',
              contentPadding: const EdgeInsets.all(SignmeSpacing.md),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 4),
          child: Text(
            '${state.note.length}/100',
            style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
          ),
        ),
      ],
    );
  }

  Widget _operatorRow(ContributionFormState state) {
    return Row(
      children: [
        Expanded(
          child: _OperatorChoice(
            label: 'Orange Money',
            color: const Color(0xFFFF6600),
            isSelected: state.operator_ == 'ORANGE MONEY',
            onTap: () {
              _markDirty();
              ref.read(contributionFormProvider.notifier).setOperator('ORANGE MONEY');
            },
          ),
        ),
        const SizedBox(width: SignmeSpacing.md),
        Expanded(
          child: _OperatorChoice(
            label: 'MTN Money',
            color: const Color(0xFFFFCC00),
            isSelected: state.operator_ == 'MTN MOBILE MONEY',
            onTap: () {
              _markDirty();
              ref.read(contributionFormProvider.notifier).setOperator('MTN MOBILE MONEY');
            },
          ),
        ),
      ],
    );
  }

  Widget _phoneField(ContributionFormState state) {
    return Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        onChanged: (v) => ref.read(contributionFormProvider.notifier).setPhone(v),
        style: SignmeTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Ex: 6XX XXX XXX',
          prefixIcon: Container(
            margin: const EdgeInsets.all(SignmeSpacing.sm),
            padding: const EdgeInsets.all(SignmeSpacing.sm),
            decoration: BoxDecoration(
              color: SignmeColors.accentSky,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
            ),
            child: const Icon(Icons.phone_rounded, color: SignmeColors.primaryLight, size: 18),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
              vertical: SignmeSpacing.lg, horizontal: SignmeSpacing.sm),
        ),
      ),
    );
  }

  Widget _summary(int total) {
    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SignmeColors.primaryDark, SignmeColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        boxShadow: [
          BoxShadow(color: SignmeColors.primaryLight.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total à payer', style: SignmeTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.8))),
          const SizedBox(width: SignmeSpacing.sm),
          Flexible(
            child: Text(
              FinanceFormatters.fcfa(total),
              style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
        child: Text(
          t,
          style: SignmeTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: SignmeColors.onSurface,
            fontSize: 15,
          ),
        ),
      );

  Widget _buildPaymentStatus(ContributionFormState state) {
    final isProcessing = state.paymentStatus == 'processing';
    final isCompleted = state.paymentStatus == 'completed';
    final isFailed = state.paymentStatus == 'failed';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SignmeSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : isFailed
                      ? Icons.error_outline_rounded
                      : state.paymentMethod == 'card'
                          ? Icons.credit_card_rounded
                          : Icons.phone_android_rounded,
              color: isCompleted
                  ? SignmeColors.success
                  : isFailed
                      ? SignmeColors.error
                      : SignmeColors.primaryLight,
              size: 80,
            ),
            const SizedBox(height: SignmeSpacing.lg),
            Text(
              isCompleted
                  ? 'Contribution réussie'
                  : isFailed
                      ? 'Paiement non confirmé'
                      : state.paymentMethod == 'card'
                          ? 'Paiement par carte'
                          : 'Confirmez sur votre téléphone',
              style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SignmeSpacing.md),
            if (isProcessing) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
                child: LinearProgressIndicator(
                  value: state.paymentProgress > 0 ? state.paymentProgress : null,
                  minHeight: 8,
                  backgroundColor: SignmeColors.lightGrayBorder.withOpacity(0.5),
                  color: SignmeColors.primaryLight,
                ),
              ),
              const SizedBox(height: SignmeSpacing.md),
            ],
            if (!isFailed)
              Text(
                state.paymentMessage ??
                    (isProcessing
                        ? (state.paymentMethod == 'card'
                            ? 'Complétez votre paiement par carte.'
                            : 'Validez le PUSH ${state.operator_} sur votre mobile.')
                        : 'Merci pour votre contribution.'),
                textAlign: TextAlign.center,
                style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.mediumGray, height: 1.4),
              ),
            if (state.error != null && isFailed) ...[
              const SizedBox(height: SignmeSpacing.sm),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error),
              ),
            ],
            const SizedBox(height: SignmeSpacing.xl),
            if (!isProcessing)
              SignmePrimaryButton(
                label: isFailed ? 'Réessayer' : 'Fermer',
                onPressed: () {
                  ref.read(contributionFormProvider.notifier).reset();
                  if (!isFailed) {
                    ref.read(formDirtyProvider.notifier).state = false;
                    if (context.canPop()) context.pop();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _OperatorChoice extends StatelessWidget {
  const _OperatorChoice({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SignmeSpacing.animationFast,
        padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md, horizontal: SignmeSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          border: Border.all(color: isSelected ? color : SignmeColors.lightGrayBorder, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: SignmeSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: SignmeTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : SignmeColors.darkGray,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_circle_rounded, color: color, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
