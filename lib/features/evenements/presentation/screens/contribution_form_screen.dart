import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../../groupes/domain/entities/groupe_contribution_target.dart';
import '../../domain/entities/evenement_entity.dart';
import '../../domain/entities/card_payment_config_entity.dart';
import '../providers/contribution_form_provider.dart';

/// Formulaire de contribution à un événement + suivi du paiement NotchPay.
///
/// [evenement] null = don libre à l'église (service « Faire un don ») : même
/// formulaire et même paiement, sans événement. [groupe] = contribution ou don
/// à la caisse d'un groupe (même formulaire, mêmes frais, même paiement).
class ContributionFormScreen extends ConsumerStatefulWidget {
  const ContributionFormScreen({super.key, this.evenement, this.groupe});

  final EvenementEntity? evenement;
  final GroupeContributionTarget? groupe;

  @override
  ConsumerState<ContributionFormScreen> createState() => _ContributionFormScreenState();
}

class _ContributionFormScreenState extends ConsumerState<ContributionFormScreen> {
  final _montantCtrl = TextEditingController(text: '500');
  final _noteCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  int _step = 0;

  bool get _isDon => widget.evenement == null && (widget.groupe?.estDonLibre ?? true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(formDirtyProvider.notifier).state = false;
    });
    for (final controller in [_montantCtrl, _noteCtrl, _phoneCtrl]) {
      controller.addListener(_markDirty);
    }

    // Taux de frais de carte fourni par le serveur (l'option carte n'apparaît
    // que si le serveur l'active : sinon le formulaire reste inchangé).
    ref.listenManual<AsyncValue<CardPaymentConfigEntity>>(
      cardPaymentConfigProvider,
      (_, next) {
        final config = next.valueOrNull;
        if (config != null) {
          ref.read(contributionFormProvider.notifier).setCardFeePercent(config.feePercent);
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    _noteCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  /// Point d'écriture unique du drapeau global — appelé par tout champ
  /// modifié par l'utilisateur (montant, note, téléphone, groupe, opérateur).
  void _markDirty() {
    if (!ref.read(formDirtyProvider)) {
      ref.read(formDirtyProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contributionFormProvider);
    // Contribution à un groupe : l'argent va à sa caisse, le groupe du
    // contributeur n'a pas à être choisi.
    final groupes = widget.groupe != null
        ? const <GroupeRef>[]
        : ref.watch(authNotifierProvider).auth?.user.groupes ?? const <GroupeRef>[];

    // Carte : ouvre la page de paiement sécurisée dès qu'elle est prête, et la
    // referme (iOS) quand le paiement est terminé.
    ref.listen<ContributionFormState>(contributionFormProvider, (previous, next) {
      if (next.isCard && next.checkoutUrl != null && previous?.checkoutUrl != next.checkoutUrl) {
        _openCheckout(next.checkoutUrl!);
      }
      final finished = next.paymentStatus == 'completed' || next.paymentStatus == 'failed';
      if (next.isCard && finished && previous?.paymentStatus != next.paymentStatus) {
        closeInAppWebView();
      }
    });
    final cardConfig = ref.watch(cardPaymentConfigProvider).valueOrNull ?? CardPaymentConfigEntity.disabled;

    return SignmeUnsavedChangesGuard(
      child: Scaffold(
        backgroundColor: SignmeColors.background,
        appBar: SignmePageAppBar(
          title: _isDon ? 'Faire un don' : 'Contribution',
        ),
        body: state.paymentStatus == 'idle'
            ? _buildForm(state, groupes, cardConfig)
            : _buildPaymentStatus(state),
      ),
    );
  }

  /// Ouvre la page de paiement hébergée dans le navigateur intégré
  /// (SFSafariViewController / Chrome Custom Tabs) : les données de carte
  /// ne transitent jamais par SignMe.
  Future<void> _openCheckout(String url) async {
    final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
    if (!opened && mounted) {
      AppSnackbar.error(context, 'Impossible d\'ouvrir la page de paiement.');
    }
  }

  Future<void> _submitPaiement(bool requiresGroupeSelection) async {
    await ref.read(contributionFormProvider.notifier).effectuerPaiement(
          widget.evenement?.uuid,
          requiresGroupeSelection: requiresGroupeSelection,
          groupeUuid: widget.groupe?.groupeUuid,
          communiqueUuid: widget.groupe?.communiqueUuid,
        );
  }

  Widget _buildForm(ContributionFormState state, List<GroupeRef> groupes, CardPaymentConfigEntity cardConfig) {
    final requiresGroupeSelection = groupes.length > 1;
    final evenement = widget.evenement;
    final churchNom = evenement?.church.nom ?? ref.watch(authNotifierProvider).auth?.user.churchNom;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          SignmeSpacing.lg, SignmeSpacing.lg, SignmeSpacing.lg, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heroHeader(evenement?.titre ?? widget.groupe?.communiqueTitre ?? widget.groupe?.groupeNom, churchNom, isEvent: evenement != null),
          const SizedBox(height: SignmeSpacing.xl),

          SignmeStepHeader(
            currentStep: _step,
            stepLabels: const ['Détails', 'Paiement'],
          ),
          const SizedBox(height: SignmeSpacing.xl),

          _step == 0
              ? _stepDetails(state, groupes, requiresGroupeSelection)
              : _stepPaiement(state, requiresGroupeSelection, cardConfig),
        ],
      ),
    );
  }

  Widget _stepDetails(
      ContributionFormState state, List<GroupeRef> groupes, bool requiresGroupeSelection) {
    final frais = state.frais;
    final total = state.total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        _sectionTitle(_isDon ? 'Montant du don (FCFA)' : 'Montant de la contribution (FCFA)'),
        _montantField(),
        const SizedBox(height: SignmeSpacing.md),
        _quickAmounts(state.montant),
        const SizedBox(height: SignmeSpacing.lg),
        _feeDisplay(frais, total),

        const SizedBox(height: SignmeSpacing.xl),
        _sectionTitle('Note (optionnelle)'),
        _noteField(state),

        const SizedBox(height: SignmeSpacing.xl),
        SignmePrimaryButton(
          label: 'Valider',
          enabled: frais != null && (!requiresGroupeSelection || state.selectedGroupeId != null),
          onPressed: () => setState(() => _step = 1),
        ),
      ],
    );
  }

  Widget _stepPaiement(
      ContributionFormState state, bool requiresGroupeSelection, CardPaymentConfigEntity cardConfig) {
    final total = state.total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignmeStepBackButton(onPressed: () => setState(() => _step = 0)),
        const SizedBox(height: SignmeSpacing.md),

        if (cardConfig.enabled) ...[
          _sectionTitle('Moyen de paiement'),
          SignmePaymentMethodSelector(
            selected: state.paymentMethod,
            onChanged: (method) {
              _markDirty();
              ref.read(contributionFormProvider.notifier).setPaymentMethod(method);
            },
          ),
          const SizedBox(height: SignmeSpacing.xl),
        ],

        if (state.isCard)
          SignmeCardPaymentInfo(
            feesLabel: state.frais == null ? null : FinanceFormatters.fcfaShort(state.frais!),
          )
        else ...[
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
          label: state.isCard ? 'Payer par carte' : 'Effectuer le paiement',
          enabled: state.isCard || state.phone.length == 9,
          isLoading: state.isLoading,
          icon: state.isCard ? Icons.credit_card_rounded : Icons.volunteer_activism_rounded,
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

  /// En-tête : pastille d'icône + intitulé + église, dans une carte douce.
  Widget _heroHeader(String? titre, String? churchNom, {required bool isEvent}) {
    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SignmeColors.primaryDark, SignmeColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            ),
            child: Icon(
              isEvent ? Icons.event_available_rounded : Icons.volunteer_activism_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: SignmeSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEvent
                      ? 'Contribution à l\'événement'
                      : widget.groupe != null
                          ? (widget.groupe!.estDonLibre ? 'Don au groupe' : 'Contribution — ${widget.groupe!.groupeNom}')
                          : 'Don libre à votre église',
                  style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
                ),
                const SizedBox(height: 2),
                Text(
                  titre ?? churchNom ?? 'Votre église',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                if (isEvent && churchNom != null)
                  Text(
                    churchNom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _quickAmountValues = [500, 1000, 2000, 5000, 10000];

  /// Montants rapides : même langage visuel que la grille des mois de la
  /// signature (carte sélectionnable, bordure et ombre bleues).
  Widget _quickAmounts(int montant) {
    return Wrap(
      spacing: SignmeSpacing.sm,
      runSpacing: SignmeSpacing.sm,
      children: [
        for (final value in _quickAmountValues)
          Semantics(
            button: true,
            selected: montant == value,
            label: FinanceFormatters.fcfaShort(value),
            child: GestureDetector(
              onTap: () {
                _markDirty();
                _montantCtrl.value = TextEditingValue(
                  text: '$value',
                  selection: TextSelection.collapsed(offset: '$value'.length),
                );
                ref.read(contributionFormProvider.notifier).setMontant(value);
              },
              child: AnimatedContainer(
                duration: SignmeSpacing.animationFast,
                padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg, vertical: SignmeSpacing.md),
                decoration: BoxDecoration(
                  color: montant == value
                      ? SignmeColors.primaryLight.withOpacity(0.08)
                      : SignmeColors.white,
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                  border: Border.all(
                    color: montant == value ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
                    width: montant == value ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: montant == value
                          ? SignmeColors.primaryLight.withOpacity(0.15)
                          : Colors.black.withOpacity(0.03),
                      blurRadius: montant == value ? 6 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  FinanceFormatters.fcfaShort(value),
                  style: SignmeTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: montant == value ? SignmeColors.primaryLight : SignmeColors.onSurface,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Récapitulatif : lignes don / frais, puis total mis en avant.
  Widget _feeDisplay(int? frais, int? total) {
    if (frais == null) {
      return Container(
        padding: const EdgeInsets.all(SignmeSpacing.lg),
        decoration: BoxDecoration(
          color: SignmeColors.error.withOpacity(0.06),
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
          border: Border.all(color: SignmeColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: SignmeColors.error, size: 20),
            const SizedBox(width: SignmeSpacing.sm),
            Expanded(
              child: Text(
                'Montant invalide : entre 500 et 1 000 000 FCFA, par multiples de 50.',
                style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error),
              ),
            ),
          ],
        ),
      );
    }
    final montant = int.tryParse(_montantCtrl.text) ?? 0;
    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        color: SignmeColors.accentSky,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.primaryLight.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          _feeRow(Icons.volunteer_activism_outlined, _isDon ? 'Don' : 'Contribution', FinanceFormatters.fcfaShort(montant)),
          const SizedBox(height: SignmeSpacing.sm),
          _feeRow(Icons.account_balance_wallet_outlined, 'Frais', FinanceFormatters.fcfaShort(frais)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md),
            child: Divider(height: 1, color: SignmeColors.primaryLight.withOpacity(0.2)),
          ),
          _feeRow(Icons.payments_outlined, 'Total à payer', FinanceFormatters.fcfaShort(total ?? 0), highlight: true),
        ],
      ),
    );
  }

  Widget _feeRow(IconData icon, String label, String value, {bool highlight = false}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
          ),
          child: Icon(icon, color: SignmeColors.primaryLight, size: 17),
        ),
        const SizedBox(width: SignmeSpacing.md),
        Expanded(
          child: Text(
            label,
            style: SignmeTypography.bodyMedium.copyWith(
              color: highlight ? SignmeColors.onSurface : SignmeColors.darkGray,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: SignmeTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: highlight ? SignmeColors.primaryLight : SignmeColors.black,
            fontSize: highlight ? 18 : 15,
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
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
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
            logoAsset: 'assets/icones/orange_money.jpg',
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
            logoAsset: 'assets/icones/mtn_money.jpg',
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
    return SignmeHeroCard(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
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
                      : state.isCard
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
                  ? (_isDon ? 'Don réussi' : 'Contribution réussie')
                  : isFailed
                      ? 'Paiement non confirmé'
                      : state.isCard
                          ? 'Finalisez le paiement'
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
                        ? 'Validez le PUSH ${state.operator_} sur votre mobile.'
                        : (_isDon ? 'Merci pour votre don.' : 'Merci pour votre contribution.')),
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
            // Carte : page de paiement fermée par erreur → on peut la rouvrir
            // pendant que l'application suit toujours le paiement.
            if (isProcessing && state.isCard && state.checkoutUrl != null) ...[
              SignmeSecondaryButton(
                label: 'Rouvrir la page de paiement',
                icon: Icons.open_in_new_rounded,
                onPressed: () => _openCheckout(state.checkoutUrl!),
              ),
              const SizedBox(height: SignmeSpacing.md),
            ],
            if (!isProcessing)
              SignmePrimaryButton(
                label: isFailed ? 'Réessayer' : 'Fermer',
                onPressed: () {
                  ref.read(contributionFormProvider.notifier).reset();
                  setState(() => _step = 0);
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
    required this.logoAsset,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final String logoAsset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: SignmeSpacing.animationFast,
          padding: const EdgeInsets.all(SignmeSpacing.xs),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.08) : SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            border: Border.all(color: isSelected ? color : SignmeColors.lightGrayBorder, width: isSelected ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
                child: SizedBox(
                  width: 72,
                  height: 40,
                  child: Image.asset(logoAsset, fit: BoxFit.cover),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      color: SignmeColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle_rounded, color: color, size: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
