import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/signer_provider.dart';
import '../providers/ma_carte_provider.dart';

class SignerScreen extends ConsumerStatefulWidget {
  const SignerScreen({super.key});

  @override
  ConsumerState<SignerScreen> createState() => _SignerScreenState();
}

class _SignerScreenState extends ConsumerState<SignerScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  late TabController _tab;

  // ── Navigation par étapes (formulaires "stepper") ────────────────────────
  // État purement local à l'écran (pas dans signerProvider) : c'est de la
  // navigation UI, pas une donnée métier partagée/persistée.
  int _distanceStep = 0;
  int _presentielStep = 0;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).auth?.user;
    final canPres = user != null && AppPermissions.canSignPresentiel(user);
    _tab = TabController(length: canPres ? 2 : 1, vsync: this);

    if (canPres) {
      WidgetsBinding.instance.addPostFrameCallback(
              (_) => ref.read(signerProvider.notifier).loadMembers(user!));
      // La vérification des horaires ne concerne QUE les anciens de service.
      // Le pasteur a toujours le droit de signer en présentiel sans
      // contrainte d'horaires → on ne doit pas appeler cet endpoint pour lui.
      if (user!.isAncien && user.estDeService) {
        WidgetsBinding.instance.addPostFrameCallback(
                (_) => ref.read(signerProvider.notifier).checkPresentielAvailability());
      }
    }
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => ref
          .read(signerProvider.notifier)
          .loadAlreadySignedMonths(user.id, DateTime.now().year));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(formDirtyProvider.notifier).state = false;
    });
    _phoneCtrl.addListener(_markDirty);
  }

  @override
  void dispose() {
    _tab.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  /// Point d'écriture unique du drapeau global — appelé par tout champ
  /// modifié par l'utilisateur, sur les deux formulaires (distance et
  /// présentiel) partageant le même [signerProvider].
  void _markDirty() {
    if (!ref.read(formDirtyProvider)) {
      ref.read(formDirtyProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signerProvider);
    final user = ref.watch(authNotifierProvider).auth?.user;
    final canPres = user != null && AppPermissions.canSignPresentiel(user);

    // Paroissien non communiant : ni signature à distance (pour lui-même)
    // ni présentiel (n'a jamais ce droit) — écran entièrement bloqué, même
    // en accès direct (le FAB qui y mène est déjà masqué côté MainShell).
    if (user != null && !canPres && !AppPermissions.canSignDistance(user)) {
      return const SignmeNoPermissionState(
        title: 'Fonctionnalité bloquée',
        message: AppPermissions.notCommuniantMessage,
        icon: Icons.block_rounded,
      );
    }

    // Point d'écriture unique de l'affichage des erreurs de signature —
    // couvre les deux formulaires (distance et présentiel) qui partagent
    // le même signerProvider, qu'il s'agisse d'une erreur de validation
    // (numéro invalide) ou d'un rejet serveur (ex: mois déjà signé).
    ref.listen<SignerState>(signerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        AppSnackbar.error(context, next.error!);
        ref.read(signerProvider.notifier).clearError();
      }
    });

    if (state.success && state.successType == 'distance') {
      return _buildSuccessContent(state);
    }
    if (state.success && state.successType == 'presentiel') {
      return _buildSuccessPresentielContent(state);
    }

    return SignmeUnsavedChangesGuard(
      child: Column(
        children: [
          if (canPres)
            Container(
              color: SignmeColors.white,
              child: TabBar(
                controller: _tab,
                labelColor: SignmeColors.primaryLight,
                unselectedLabelColor: SignmeColors.mediumGray,
                indicatorColor: SignmeColors.primaryLight,
                indicatorWeight: 3,
                labelStyle: SignmeTypography.labelSmall
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: SignmeTypography.labelSmall
                    .copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(text: 'Distance'),
                  Tab(text: 'Présentiel'),
                ],
              ),
            ),
          Expanded(
            child: canPres
                ? TabBarView(
              controller: _tab,
              children: [_distanceForm(state), _presentielForm(state)],
            )
                : _distanceForm(state),
          ),
        ],
      ),
    );
  }

  // ── Success screens (inchangés) ──────────────────────────────────────────

  Widget _buildSuccessContent(SignerState state) {
    final isProcessing =
        state.paymentStatus == 'processing' || state.paymentStatus == 'pending';
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
                  ? 'Paiement réussi'
                  : isFailed
                  ? 'Paiement non confirmé'
                  : 'Confirmez sur votre téléphone',
              style: SignmeTypography.headlineSmall
                  .copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SignmeSpacing.md),
            if (isProcessing) ...[
              ClipRRect(
                borderRadius:
                BorderRadius.circular(SignmeSpacing.radiusSm),
                child: LinearProgressIndicator(
                  value: state.paymentProgress > 0
                      ? state.paymentProgress
                      : null,
                  minHeight: 8,
                  backgroundColor:
                  SignmeColors.lightGrayBorder.withOpacity(0.5),
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
                        : 'Signature enregistrée.'),
                textAlign: TextAlign.center,
                style: SignmeTypography.bodyMedium
                    .copyWith(color: SignmeColors.mediumGray, height: 1.4),
              ),
            if (state.error != null && isFailed) ...[
              const SizedBox(height: SignmeSpacing.sm),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: SignmeTypography.bodySmall
                    .copyWith(color: SignmeColors.error),
              ),
            ],
            const SizedBox(height: SignmeSpacing.xl),
            if (!isProcessing)
              SignmePrimaryButton(
                label: isFailed ? 'Réessayer' : 'Fermer',
                onPressed: () {
                  ref.read(signerProvider.notifier).reset();
                  ref.read(formDirtyProvider.notifier).state = false;
                  setState(() => _distanceStep = 0);
                  if (!isFailed) context.pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessPresentielContent(SignerState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 80, color: SignmeColors.success),
          const SizedBox(height: SignmeSpacing.lg),
          Text('Signature Enregistrée',
              style: SignmeTypography.headlineSmall
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: SignmeSpacing.xl),
          SignmePrimaryButton(
            label: 'Fermer',
            onPressed: () {
              ref.read(signerProvider.notifier).reset();
              ref.read(formDirtyProvider.notifier).state = false;
              setState(() => _presentielStep = 0);
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  // ── Formulaire Distance ──────────────────────────────────────────────────

  /// Formulaire à distance en 2 étapes : (1) période — montant/année/mois,
  /// validée côté backend comme avant (aucune règle métier déplacée ici) ;
  /// (2) paiement — opérateur mobile money + numéro (la carte bancaire ne
  /// fonctionne pas en production, retirée du choix proposé à l'utilisateur).
  Widget _distanceForm(SignerState state) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.lg, SignmeSpacing.lg, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SignmeStepHeader(
              currentStep: _distanceStep,
              stepLabels: const ['Période', 'Paiement'],
            ),
            const SizedBox(height: SignmeSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: _distanceStep == 0
                    ? _distanceStepPeriode(state)
                    : _distanceStepPaiement(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _distanceStepPeriode(SignerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Sélectionner l\'année'),
        _yearGrid(state, false),
        const SizedBox(height: SignmeSpacing.xl),
        _sectionTitle('Sélectionner les mois (${state.selectedYear})'),
        const SizedBox(height: SignmeSpacing.sm),
        _monthGrid(
          state,
          state.selectedYear,
          false,
          signedMonths: state.alreadySignedMonths,
          onToggle: (m) => ref.read(signerProvider.notifier).toggleMonth(m),
        ),
        const SizedBox(height: SignmeSpacing.xl),
        SignmePrimaryButton(
          label: 'Valider',
          enabled: state.selectedMonths.isNotEmpty,
          onPressed: () => setState(() => _distanceStep = 1),
        ),
      ],
    );
  }

  Widget _distanceStepPaiement(SignerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignmeStepBackButton(onPressed: () => setState(() => _distanceStep = 0)),
        const SizedBox(height: SignmeSpacing.md),
        _sectionTitle('Montant de la signature'),
        _amountDropdown(state, false),
        const SizedBox(height: SignmeSpacing.md),
        _feeDisplay(state),
        const SizedBox(height: SignmeSpacing.xl),
        _sectionTitle('Opérateur'),
        const SizedBox(height: SignmeSpacing.sm),
        _operatorRow(state),
        const SizedBox(height: SignmeSpacing.xl),
        _sectionTitle('Numéro de paiement'),
        const SizedBox(height: SignmeSpacing.sm),
        _phoneField(state),
        const SizedBox(height: SignmeSpacing.xl),
        _summary(state),
        const SizedBox(height: SignmeSpacing.lg),
        SignmePrimaryButton(
          label: 'Confirmer le paiement',
          enabled: state.phone.length == 9,
          isLoading: state.isLoading,
          onPressed: _submitDistance,
        ),
      ],
    );
  }

  // ── Formulaire Présentiel ────────────────────────────────────────────────

  /// Formulaire présentiel en 3 étapes : (1) recherche/sélection du membre —
  /// photo, nom, identifiant affichés, validée par la personne qui signe ;
  /// (2) année + mois, avec repère "Signé"/"Non signé" par mois pour CE
  /// membre (nouveau — voir [SignerNotifier.loadMemberSignedMonths]) ; (3)
  /// montant de l'offrande + enregistrement. Aucune règle métier déplacée :
  /// mêmes appels backend qu'avant, juste répartis sur 3 écrans.
  Widget _presentielForm(SignerState state) {
    final user = ref.watch(authNotifierProvider).auth?.user;
    final isAncienNotInService = user != null && user.isAncien && !user.estDeService;
    // Allow form during checking (loading), but enforce restriction after check completes
    final canSignNow = state.isCheckingPresentielAvailability ? true : state.canSignPresentielNow;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.lg, SignmeSpacing.lg, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SignmeStepHeader(
                currentStep: _presentielStep,
                stepLabels: const ['Membre', 'Période', 'Montant'],
              ),
              const SizedBox(height: SignmeSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: switch (_presentielStep) {
                    0 => _presentielStepMember(state, isAncienNotInService, canSignNow),
                    1 => _presentielStepPeriode(state, isAncienNotInService),
                    _ => _presentielStepMontant(state, isAncienNotInService),
                  },
                ),
              ),
            ],
          ),
        ),
        if (isAncienNotInService)
          Positioned.fill(
            child: Container(
              color: SignmeColors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(SignmeSpacing.lg),
                  decoration: BoxDecoration(
                    color: SignmeColors.white,
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 48,
                        color: SignmeColors.error,
                      ),
                      const SizedBox(height: SignmeSpacing.md),
                      Text(
                        'Accès Restreint',
                        style: SignmeTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: SignmeColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: SignmeSpacing.sm),
                      Text(
                        'Vous devez être désigné comme\nancien de service pour signer\nles cartes en présentiel.',
                        textAlign: TextAlign.center,
                        style: SignmeTypography.bodyMedium.copyWith(
                          color: SignmeColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (!canSignNow && !isAncienNotInService && state.isCheckingPresentielAvailability)
          Positioned.fill(
            child: Container(
              color: SignmeColors.black.withOpacity(0.3),
              child: const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: SignmeColors.primaryLight,
                  ),
                ),
              ),
            ),
          ),
        if (!canSignNow && !isAncienNotInService && !state.isCheckingPresentielAvailability)
          Positioned.fill(
            child: Container(
              color: SignmeColors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(SignmeSpacing.lg),
                  decoration: BoxDecoration(
                    color: SignmeColors.white,
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 48,
                        color: SignmeColors.error,
                      ),
                      const SizedBox(height: SignmeSpacing.md),
                      Text(
                        'Horaires de Service',
                        style: SignmeTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: SignmeColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: SignmeSpacing.sm),
                      Text(
                        'Vous pouvez signer seulement\npendant vos horaires de service.',
                        textAlign: TextAlign.center,
                        style: SignmeTypography.bodyMedium.copyWith(
                          color: SignmeColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _presentielStepMember(
    SignerState state,
    bool isAncienNotInService,
    bool canSignNow,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Sélectionner le membre'),
        const SizedBox(height: SignmeSpacing.sm),
        TextField(
          enabled: !isAncienNotInService && canSignNow,
          onChanged: (q) {
            ref.read(signerProvider.notifier).updateMemberSearch(q);
            if (q.length >= 2) {
              ref.read(signerProvider.notifier).searchMembers(q);
            }
          },
          style: SignmeTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Rechercher par nom...',
            prefixIcon: const Icon(Icons.search, color: SignmeColors.mediumGray),
            filled: true,
            fillColor: SignmeColors.accentSky.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (state.memberSearchQuery.length >= 2 &&
            state.filteredMembers.isNotEmpty &&
            state.selectedUserId == null &&
            !isAncienNotInService &&
            canSignNow)
          Container(
            margin: const EdgeInsets.only(top: SignmeSpacing.xs),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: SignmeColors.white,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              border: Border.all(color: SignmeColors.lightGrayBorder),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: state.filteredMembers.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              itemBuilder: (context, index) {
                final member = state.filteredMembers[index];
                return ListTile(
                  dense: true,
                  leading: GestureDetector(
                    onTap: member.photoUrl != null
                        ? () => _showPhotoDialog(context, member.photoUrl!, member.nom)
                        : null,
                    child: _MemberAvatar(
                      photoUrl: member.photoUrl,
                      nom: member.nom,
                      radius: 20,
                    ),
                  ),
                  title: Text(member.nom,
                      style: SignmeTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      member.matricule != null
                          ? '${member.roleLabel} · ${member.matricule}'
                          : member.roleLabel,
                      style: SignmeTypography.bodySmall),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _markDirty();
                    ref.read(signerProvider.notifier).selectUser(member.id, member.nom);
                  },
                );
              },
            ),
          ),
        if (state.selectedUserId != null) ...[
          const SizedBox(height: SignmeSpacing.md),
          _memberSummaryCard(state),
          const SizedBox(height: SignmeSpacing.xl),
          SignmePrimaryButton(
            label: 'Valider',
            enabled: !isAncienNotInService && canSignNow,
            onPressed: () {
              setState(() => _presentielStep = 1);
              ref
                  .read(signerProvider.notifier)
                  .loadMemberSignedMonths(state.selectedUserId!, state.selectedYear);
            },
          ),
        ],
      ],
    );
  }

  Widget _presentielStepPeriode(SignerState state, bool isAncienNotInService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignmeStepBackButton(onPressed: () => setState(() => _presentielStep = 0)),
        const SizedBox(height: SignmeSpacing.md),
        _memberSummaryCard(state, showRemoveButton: false),
        const SizedBox(height: SignmeSpacing.xl),
        _sectionTitle('Sélectionner l\'année'),
        _yearGrid(
          state,
          isAncienNotInService,
          onYearSelected: () => ref
              .read(signerProvider.notifier)
              .loadMemberSignedMonths(state.selectedUserId!, state.selectedYear),
        ),
        const SizedBox(height: SignmeSpacing.xl),
        _sectionTitle('Sélectionner les mois'),
        const SizedBox(height: SignmeSpacing.sm),
        if (state.isLoadingMemberSignedMonths)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: SignmeSpacing.lg),
            child: Center(
              child: CircularProgressIndicator(color: SignmeColors.primaryLight),
            ),
          )
        else
          _monthGrid(
            state,
            state.selectedYear,
            isAncienNotInService,
            signedMonths: state.memberSignedMonths,
            onToggle: (m) => ref.read(signerProvider.notifier).togglePresentielMonth(m),
          ),
        const SizedBox(height: SignmeSpacing.xl),
        SignmePrimaryButton(
          label: 'Valider',
          enabled: !isAncienNotInService && state.selectedMonths.isNotEmpty,
          onPressed: () => setState(() => _presentielStep = 2),
        ),
      ],
    );
  }

  Widget _presentielStepMontant(SignerState state, bool isAncienNotInService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignmeStepBackButton(onPressed: () => setState(() => _presentielStep = 1)),
        const SizedBox(height: SignmeSpacing.md),
        _memberSummaryCard(state, showRemoveButton: false),
        const SizedBox(height: SignmeSpacing.xl),
        _sectionTitle('Montant de l\'offrande'),
        const SizedBox(height: SignmeSpacing.sm),
        _amountDropdown(state, isAncienNotInService),
        const SizedBox(height: SignmeSpacing.xl),
        _summary(state),
        const SizedBox(height: SignmeSpacing.lg),
        SignmePrimaryButton(
          label: 'Enregistrer Signature',
          enabled: !isAncienNotInService &&
              state.selectedUserId != null &&
              state.selectedMonths.isNotEmpty,
          isLoading: state.isLoading,
          onPressed: _submitPresentiel,
        ),
      ],
    );
  }

  // ── Composants UI premium ────────────────────────────────────────────────

  /// Dropdown montant : ligne icône dans cercle bleu clair + montant
  Widget _amountDropdown(SignerState state, bool isAncienNotInService) {
    return Opacity(
      opacity: isAncienNotInService ? 0.4 : 1.0,
      child: AbsorbPointer(
        absorbing: isAncienNotInService,
        child: SignmeCompactDropdown<int>(
          label: 'Montant',
          showLabel: false,
          value: state.amountPerMonth,
          items: SignerState.ALLOWED_AMOUNTS,
          itemLabel: (a) => '$a FCFA',
          itemHeight: 64,
          itemBuilderLeadingWidth: 40 + SignmeSpacing.md,
          itemBuilder: (a, selected) => Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SignmeColors.accentSky,
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                ),
                child: const Icon(Icons.credit_card_rounded, color: SignmeColors.primaryLight, size: 20),
              ),
              const SizedBox(width: SignmeSpacing.md),
              Expanded(
                child: Text(
                  '$a FCFA',
                  style: SignmeTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: SignmeColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          onChanged: (v) {
            if (v == null) return;
            _markDirty();
            ref.read(signerProvider.notifier).setAmount(v);
          },
        ),
      ),
    );
  }

  /// Card frais : fond bleu très clair, icône à gauche, montant bleu gras
  Widget _feeDisplay(SignerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SignmeSpacing.lg, vertical: SignmeSpacing.md),
      decoration: BoxDecoration(
        color: SignmeColors.accentSky,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(
            color: SignmeColors.primaryLight.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                color: SignmeColors.primaryLight, size: 18),
          ),
          const SizedBox(width: SignmeSpacing.md),
          Text(
            'Frais par mois',
            style: SignmeTypography.bodyMedium
                .copyWith(color: SignmeColors.darkGray),
          ),
          const Spacer(),
          Text(
            '${state.feesPerMonth} FCFA',
            style: SignmeTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: SignmeColors.primaryLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Grid années : 3 colonnes, card rectangulaire, sélectionné = bleu + check
  Widget _yearGrid(
    SignerState state,
    bool isAncienNotInService, {
    VoidCallback? onYearSelected,
  }) {
    final years = List.generate(5, (i) => 2026 + i);
    return Opacity(
      opacity: isAncienNotInService ? 0.4 : 1.0,
      child: AbsorbPointer(
        absorbing: isAncienNotInService,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // Largeur max par colonne (plutôt qu'un nombre de colonnes fixe) :
          // 3 colonnes sur un téléphone, davantage sur une tablette — au
          // lieu de cellules étirées/disproportionnées.
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            mainAxisSpacing: SignmeSpacing.sm,
            crossAxisSpacing: SignmeSpacing.sm,
            childAspectRatio: 2.2,
          ),
          itemCount: years.length,
          itemBuilder: (context, i) {
            final y = years[i];
            final selected = state.selectedYear == y;
            return GestureDetector(
              onTap: () {
                _markDirty();
                ref.read(signerProvider.notifier).setYear(y);
                onYearSelected?.call();
              },
              child: AnimatedContainer(
                duration: SignmeSpacing.animationFast,
                decoration: BoxDecoration(
                  color: selected ? SignmeColors.primaryLight : SignmeColors.white,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              border: Border.all(
                color: selected
                    ? SignmeColors.primaryLight
                    : SignmeColors.lightGrayBorder,
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                  color: SignmeColors.primaryLight.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected) ...[
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                ],
                Text(
                  y.toString(),
                  style: SignmeTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : SignmeColors.darkGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
        )
      )
    );
  }

  /// Grid mois : 4 colonnes, icône calendrier au-dessus du label
  /// [signedMonths] : "distance" passe `state.alreadySignedMonths` (mois
  /// déjà signés par l'utilisateur connecté) ; "présentiel" passe
  /// `state.memberSignedMonths` (mois déjà signés par le membre sélectionné)
  /// — même widget, deux sources de vérité selon le contexte d'appel.
  Widget _monthGrid(
    SignerState state,
    int year,
    bool isAncienNotInService, {
    required List<String> signedMonths,
    required void Function(String month) onToggle,
  }) {
    return Opacity(
      opacity: isAncienNotInService ? 0.4 : 1.0,
      child: AbsorbPointer(
        absorbing: isAncienNotInService,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // Largeur max par colonne (plutôt qu'un nombre de colonnes fixe) :
          // 4 colonnes sur un téléphone, davantage sur une tablette — au
          // lieu de cellules démesurément grandes.
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 90,
            mainAxisSpacing: SignmeSpacing.sm,
            crossAxisSpacing: SignmeSpacing.sm,
            childAspectRatio: 1.0,
          ),
          itemCount: 12,
          itemBuilder: (context, i) {
            final month = '$year-${(i + 1).toString().padLeft(2, '0')}';
            final isSigned = signedMonths.contains(month);
            final isSelected = state.selectedMonths.contains(month);

            return GestureDetector(
              onTap: isSigned
                  ? null
                  : () {
                      _markDirty();
                      onToggle(month);
                    },
              child: AnimatedContainer(
                duration: SignmeSpacing.animationFast,
                decoration: BoxDecoration(
                  color: isSigned
                      ? SignmeColors.lightGray
                      : isSelected
                      ? SignmeColors.primaryLight.withOpacity(0.08)
                      : SignmeColors.white,
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                  border: Border.all(
                    color: isSigned
                        ? SignmeColors.lightGrayBorder
                        : isSelected
                        ? SignmeColors.primaryLight
                        : SignmeColors.lightGrayBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: SignmeColors.primaryLight.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSigned
                          ? Icons.check_circle_outline_rounded
                          : Icons.calendar_today_outlined,
                      size: 20,
                      color: isSigned
                          ? SignmeColors.mediumGray
                          : isSelected
                          ? SignmeColors.primaryLight
                          : SignmeColors.primaryLight.withOpacity(0.5),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      AppStrings.moisShort[i],
                      style: SignmeTypography.bodySmall.copyWith(
                        fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSigned
                            ? SignmeColors.mediumGray
                            : isSelected
                            ? SignmeColors.primaryLight
                            : SignmeColors.darkGray,
                        fontSize: 11,
                      ),
                    ),
                  ],
            ),
          ),
        );
      },
        )
      )
    );
  }

  /// Sélecteur opérateur : deux cards côte à côte avec logo-like
  Widget _operatorRow(SignerState state) {
    return Row(
      children: [
        Expanded(
          child: _OperatorCard(
            label: 'Orange Money',
            color: const Color(0xFFFF6600),
            logoAsset: 'assets/icones/orange_money.jpg',
            isSelected: state.operator_ == 'ORANGE MONEY',
            onTap: () {
              _markDirty();
              ref.read(signerProvider.notifier).setOperator('ORANGE MONEY');
            },
          ),
        ),
        const SizedBox(width: SignmeSpacing.md),
        Expanded(
          child: _OperatorCard(
            label: 'MTN Money',
            color: const Color(0xFFFFCC00),
            logoAsset: 'assets/icones/mtn_money.jpg',
            isSelected: state.operator_ == 'MTN MOBILE MONEY',
            onTap: () {
              _markDirty();
              ref.read(signerProvider.notifier).setOperator('MTN MOBILE MONEY');
            },
          ),
        ),
      ],
    );
  }

  /// Champ téléphone stylisé
  Widget _phoneField(SignerState state) {
    return Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        onChanged: (v) => ref.read(signerProvider.notifier).setPhone(v),
        style: SignmeTypography.bodyLarge
            .copyWith(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Ex: 6XX XXX XXX',
          hintStyle: SignmeTypography.bodyMedium
              .copyWith(color: SignmeColors.mediumGray),
          prefixIcon: Container(
            margin: const EdgeInsets.all(SignmeSpacing.sm),
            padding: const EdgeInsets.all(SignmeSpacing.sm),
            decoration: BoxDecoration(
              color: SignmeColors.accentSky,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
            ),
            child: const Icon(Icons.phone_rounded,
                color: SignmeColors.primaryLight, size: 18),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
              vertical: SignmeSpacing.lg, horizontal: SignmeSpacing.sm),
        ),
      ),
    );
  }

  /// Card récap total
  Widget _summary(SignerState state) {
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
          BoxShadow(
            color: SignmeColors.primaryLight.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total à payer',
                  style: SignmeTypography.bodySmall
                      .copyWith(color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.selectedMonths.length} mois sélectionné${state.selectedMonths.length > 1 ? 's' : ''}',
                  style: SignmeTypography.bodySmall
                      .copyWith(color: Colors.white.withOpacity(0.65), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: SignmeSpacing.sm),
          Flexible(
            child: Text(
              '${state.totalAmount} FCFA',
              style: SignmeTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 22,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberSummaryCard(SignerState state, {bool showRemoveButton = true}) {
    // Retrouver le membre sélectionné pour avoir son photoUrl
    final selectedMember = state.filteredMembers.isEmpty
        ? null
        : state.members.where((m) => m.id == state.selectedUserId).firstOrNull;
    final photoUrl = selectedMember?.photoUrl;

    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.md),
      decoration: BoxDecoration(
        color: SignmeColors.accentSky.withOpacity(0.5),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
        border: Border.all(color: SignmeColors.primaryLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: photoUrl != null
                ? () => _showPhotoDialog(context, photoUrl, state.selectedUserNom)
                : null,
            child: Stack(
              children: [
                _MemberAvatar(
                  photoUrl: photoUrl,
                  nom: state.selectedUserNom,
                  radius: 22,
                ),
                if (photoUrl != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: SignmeColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(Icons.zoom_in_rounded,
                          color: Colors.white, size: 9),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: SignmeSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.selectedUserNom,
                  style: SignmeTypography.labelLarge
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                if (selectedMember != null)
                  Text(
                    selectedMember.matricule != null
                        ? '${selectedMember.roleLabel} · ${selectedMember.matricule}'
                        : selectedMember.roleLabel,
                    style: SignmeTypography.bodySmall
                        .copyWith(color: SignmeColors.mediumGray),
                  ),
              ],
            ),
          ),
          if (showRemoveButton)
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  size: 20, color: SignmeColors.mediumGray),
              onPressed: () =>
                  ref.read(signerProvider.notifier).selectUser(null, ''),
            ),
        ],
      ),
    );
  }

  void _showPhotoDialog(BuildContext context, String photoUrl, String nom) {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(SignmeSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nom du membre
            Padding(
              padding: const EdgeInsets.only(bottom: SignmeSpacing.md),
              child: Text(
                nom,
                style: SignmeTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            // Photo en grand
            ClipRRect(
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                  height: 300,
                  color: SignmeColors.lightGray,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: SignmeColors.primaryLight,
                    ),
                  ),
                ),
                errorBuilder: (_, __, ___) => Container(
                  height: 300,
                  color: SignmeColors.lightGray,
                  child: const Icon(Icons.broken_image_rounded,
                      color: SignmeColors.mediumGray, size: 48),
                ),
              ),
            ),
            const SizedBox(height: SignmeSpacing.md),
            // Bouton fermer
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: SignmeSpacing.xl, vertical: SignmeSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
                  border: Border.all(color: Colors.white30),
                ),
                child: Text(
                  'Fermer',
                  style: SignmeTypography.labelMedium
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
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

  Future<void> _submitDistance() async {
    final notifier = ref.read(signerProvider.notifier);
    final ok = await notifier.initiateDistance();

    // initiateDistance() bascule l'écran vers la vue de résultat dès qu'il
    // dépasse la validation (state.success), qu'il réussisse ou échoue
    // ensuite — il n'y a alors plus de saisie à protéger.
    if (mounted && ref.read(signerProvider).success) {
      ref.read(formDirtyProvider.notifier).state = false;
    }

    if (ok && mounted) {
      ref.read(maCarteProvider.notifier).load(force: true);
    }
  }

  Future<void> _submitPresentiel() async {
    final ok = await ref.read(signerProvider.notifier).initiatePresentiel();
    if (ok && mounted) {
      ref.read(formDirtyProvider.notifier).state = false;
      ref.read(maCarteProvider.notifier).load(force: true);
    }
  }
}

// ── Member Avatar ────────────────────────────────────────────────────────────
class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.photoUrl,
    required this.nom,
    this.radius = 20,
  });

  final String? photoUrl;
  final String nom;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = nom.trim().split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: SignmeColors.accentSky,
        backgroundImage: NetworkImage(photoUrl!),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: SignmeColors.primaryLight.withOpacity(0.15),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.65,
          fontWeight: FontWeight.w700,
          color: SignmeColors.primaryLight,
        ),
      ),
    );
  }
}

// ── Operator Card ─────────────────────────────────────────────────────────────
class _OperatorCard extends StatelessWidget {
  const _OperatorCard({
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
            border: Border.all(
              color: isSelected ? color : SignmeColors.lightGrayBorder,
              width: isSelected ? 2 : 1,
            ),
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