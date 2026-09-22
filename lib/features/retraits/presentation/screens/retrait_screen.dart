import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/widgets/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/retrait_beneficiaire_entity.dart';
import '../providers/retraits_provider.dart';
import '../providers/retraits_list_provider.dart';
import '../widgets/retrait_beneficiaire_dialog.dart';
import '../widgets/retrait_card.dart';
import '../widgets/retrait_form_dialog.dart';

/// Montant minimum côté client, pour un feedback immédiat — le backend
/// (config('payment.retrait.montant_min'), .env RETRAIT_MONTANT_MIN) reste la
/// seule source de vérité, revalidé à chaque soumission.
/// ⚠ Temporairement abaissé à 100 FCFA le temps des tests avec un petit
/// solde réel — remettre à 1000 quand RETRAIT_MONTANT_MIN repasse à 1000.
const _montantMinAffiche = 100;

class RetraitScreen extends ConsumerStatefulWidget {
  const RetraitScreen({super.key});

  @override
  ConsumerState<RetraitScreen> createState() => _RetraitScreenState();
}

class _RetraitScreenState extends ConsumerState<RetraitScreen> {
  late final ScrollController _scrollController;
  String? _rechecking;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(retraitsListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      final listState = ref.read(retraitsListProvider);
      if (!listState.isLoading && listState.hasMore) {
        ref.read(retraitsListProvider.notifier).loadMore();
      }
    }
  }

  Future<void> _refreshAll() async {
    ref.invalidate(retraitSoldeProvider);
    ref.invalidate(retraitBeneficiaireProvider);
    await ref.read(retraitsListProvider.notifier).refresh();
  }

  void _openBeneficiaireDialog(RetraitBeneficiaireEntity? actuel) {
    showDialog<bool>(
      context: context,
      builder: (_) => RetraitBeneficiaireDialog(beneficiaireActuel: actuel),
    ).then((changed) {
      if (changed == true) {
        ref.invalidate(retraitBeneficiaireProvider);
      }
    });
  }

  void _openRetraitDialog(int solde, RetraitBeneficiaireEntity beneficiaire) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RetraitFormDialog(
        solde: solde,
        beneficiaire: beneficiaire,
        montantMin: _montantMinAffiche,
      ),
    ).then((submitted) {
      if (submitted == true) {
        _refreshAll();
      }
    });
  }

  Future<void> _recheck(String uuid) async {
    setState(() => _rechecking = uuid);
    try {
      await ref.read(retraitsListProvider.notifier).recheck(uuid);
    } catch (e) {
      if (mounted) AppSnackbar.error(context, messageFromError(e));
    } finally {
      if (mounted) setState(() => _rechecking = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final soldeAsync = ref.watch(retraitSoldeProvider);
    final beneficiaireAsync = ref.watch(retraitBeneficiaireProvider);
    final listState = ref.watch(retraitsListProvider);

    return Scaffold(
      backgroundColor: SignmeColors.background,
      body: RefreshIndicator(
        color: SignmeColors.primaryLight,
        onRefresh: _refreshAll,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.lg, SignmeSpacing.lg, SignmeSpacing.md),
                child: _SoldeCard(soldeAsync: soldeAsync),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                child: _BeneficiaireCard(
                  beneficiaireAsync: beneficiaireAsync,
                  onEdit: (b) => _openBeneficiaireDialog(b),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.lg, SignmeSpacing.lg, SignmeSpacing.md),
                child: SignmePrimaryButton(
                  label: 'Retrait',
                  onPressed: soldeAsync.hasValue && beneficiaireAsync.valueOrNull != null
                      ? () => _openRetraitDialog(soldeAsync.value!, beneficiaireAsync.value!)
                      : null,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.md, SignmeSpacing.lg, SignmeSpacing.sm),
                child: Text(
                  'Historique des retraits',
                  style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            if (listState.isLoading && listState.items.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: SignmeColors.primaryLight)))
            else if (listState.error != null && listState.items.isEmpty)
              SliverFillRemaining(
                child: SignmeErrorState(
                  title: 'Erreur',
                  message: listState.error!,
                  onRetry: () => ref.read(retraitsListProvider.notifier).refresh(),
                ),
              )
            else if (listState.items.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(SignmeSpacing.xl),
                    child: Text('Aucun retrait pour le moment.', style: TextStyle(color: SignmeColors.mediumGray)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == listState.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: SignmeSpacing.md),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final retrait = listState.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
                        child: RetraitCard(
                          retrait: retrait,
                          onRecheck: () => _recheck(retrait.uuid),
                          isRechecking: _rechecking == retrait.uuid,
                        ),
                      );
                    },
                    childCount: listState.items.length + (listState.hasMore ? 1 : 0),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: SignmeSpacing.navbarClearance + 40)),
          ],
        ),
      ),
    );
  }
}

class _SoldeCard extends StatelessWidget {
  const _SoldeCard({required this.soldeAsync});
  final AsyncValue<int> soldeAsync;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SignmeColors.primaryDark, SignmeColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(color: SignmeColors.primaryLight.withValues(alpha: 0.30), blurRadius: 20, offset: const Offset(0, 8)),
        ],
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      ),
      padding: const EdgeInsets.all(SignmeSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 18),
              SizedBox(width: SignmeSpacing.sm),
              Text('Solde disponible', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: SignmeSpacing.md),
          soldeAsync.when(
            loading: () => const CircularProgressIndicator(color: Colors.white),
            error: (_, __) => const Text('Erreur', style: TextStyle(color: Colors.white)),
            data: (solde) => Text(
              FinanceFormatters.fcfa(solde),
              style: SignmeTypography.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeneficiaireCard extends StatelessWidget {
  const _BeneficiaireCard({required this.beneficiaireAsync, required this.onEdit});

  final AsyncValue<RetraitBeneficiaireEntity?> beneficiaireAsync;
  final ValueChanged<RetraitBeneficiaireEntity?> onEdit;

  @override
  Widget build(BuildContext context) {
    return beneficiaireAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (beneficiaire) {
        return InkWell(
          onTap: () => onEdit(beneficiaire),
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
          child: Container(
            padding: const EdgeInsets.all(SignmeSpacing.md),
            decoration: BoxDecoration(
              color: SignmeColors.white,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
              border: Border.all(color: SignmeColors.lightGrayBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SignmeColors.accentSky,
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                  ),
                  child: Icon(
                    Icons.phone_android_rounded,
                    size: 20,
                    color: beneficiaire == null ? SignmeColors.warning : SignmeColors.primaryLight,
                  ),
                ),
                const SizedBox(width: SignmeSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        beneficiaire == null ? 'Aucun compte de retrait' : 'Compte de retrait',
                        style: SignmeTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        beneficiaire == null
                            ? 'Enregistrez votre numéro pour pouvoir retirer'
                            : '${beneficiaire.operator} · ${beneficiaire.numeroMasque}',
                        style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  beneficiaire == null ? 'Ajouter' : 'Modifier',
                  style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.primaryLight, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
