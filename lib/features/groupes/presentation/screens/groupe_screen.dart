import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/entities/groupe_contribution_target.dart';
import '../../domain/entities/groupe_entities.dart';
import '../providers/groupes_provider.dart';
import '../widgets/cash_entry_sheet.dart';
import '../widgets/communique_card.dart';
import '../widgets/communique_detail_sheet.dart';
import '../widgets/groupe_caisse_card.dart';
import '../widgets/groupe_retrait_sheet.dart';
import '../widgets/groupe_sheet.dart';
import '../widgets/mouvement_tile.dart';

/// Écran d'un groupe : caisse (visible de tous les membres), communiqués et
/// historique des entrées/sorties d'argent. Ce que chaque membre peut faire
/// dépend de son POSTE dans le groupe (le serveur le vérifie aussi) :
///   membre    : lire, contribuer, faire un don
///   président : + publier/modifier/retirer les communiqués
///   président ou trésorier : + entrées cash, retraits
class GroupeScreen extends ConsumerStatefulWidget {
  const GroupeScreen({super.key, required this.uuid});

  final String uuid;

  @override
  ConsumerState<GroupeScreen> createState() => _GroupeScreenState();
}

class _GroupeScreenState extends ConsumerState<GroupeScreen> {
  int _onglet = 0; // 0 communiqués · 1 historique
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_onglet == 1 && _scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
        ref.read(mouvementsProvider(widget.uuid).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _actualiser() async {
    refreshGroupe(ref, widget.uuid);
    try {
      await ref.read(groupeProvider(widget.uuid).future);
    } catch (_) {
      // L'erreur s'affiche dans l'écran : le geste de rafraîchissement se termine.
    }
  }

  Future<void> _contribuer(GroupeEntity groupe, {CommuniqueEntity? communique}) async {
    await context.push<void>(
      '/services/groupes/${groupe.uuid}/contribuer',
      extra: GroupeContributionTarget(
        groupeUuid: groupe.uuid,
        groupeNom: groupe.nom,
        communiqueUuid: communique?.uuid,
        communiqueTitre: communique?.titre,
      ),
    );
    if (mounted) refreshGroupe(ref, widget.uuid);
  }

  Future<void> _ouvrirCommunique(GroupeEntity groupe, CommuniqueEntity communique) async {
    final action = await showCommuniqueDetailSheet(
      context,
      groupeUuid: groupe.uuid,
      communique: communique,
      peutGerer: groupe.estPresident,
    );
    if (!mounted || action == null) return;

    switch (action) {
      case CommuniqueAction.contribuer:
        await _contribuer(groupe, communique: communique);
      case CommuniqueAction.modifier:
        await context.push<void>('/services/groupes/${groupe.uuid}/communique', extra: communique);
        if (mounted) refreshGroupe(ref, widget.uuid);
      case CommuniqueAction.retirer:
        await _retirerCommunique(groupe, communique);
    }
  }

  Future<void> _retirerCommunique(GroupeEntity groupe, CommuniqueEntity communique) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
        backgroundColor: SignmeColors.white,
        title: Text('Retirer ce communiqué ?', style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
        content: Text(
          'Il disparaîtra de la liste. Les contributions déjà reçues restent dans la caisse et l\'historique.',
          style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.mediumGray),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Retirer', style: TextStyle(color: SignmeColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;

    try {
      await ref.read(mesGroupesRemoteDataSourceProvider).archiverCommunique(groupe.uuid, communique.uuid);
      if (!mounted) return;
      refreshGroupe(ref, widget.uuid);
      AppSnackbar.success(context, 'Communiqué retiré.');
    } catch (e) {
      if (mounted) AppSnackbar.error(context, messageFromError(e));
    }
  }

  Future<void> _entreeCash(GroupeEntity groupe) async {
    final ok = await showCashEntrySheet(context, groupeUuid: groupe.uuid);
    if (ok == true && mounted) {
      refreshGroupe(ref, widget.uuid);
      AppSnackbar.success(context, 'Entrée d\'argent enregistrée.');
    }
  }

  Future<void> _retrait(GroupeEntity groupe) async {
    final ok = await showGroupeRetraitSheet(
      context,
      groupeUuid: groupe.uuid,
      soldeEnLigne: groupe.caisse?.soldeEnLigne ?? 0,
    );
    if (ok == true && mounted) refreshGroupe(ref, widget.uuid);
  }

  /// Annulation d'une entrée cash (jamais de modification ni de suppression).
  Future<void> _annulerCash(GroupeEntity groupe, MouvementEntity m) async {
    final controller = TextEditingController();
    final motif = await showGroupeSheet<String>(
      context,
      title: 'Annuler cette entrée ?',
      subtitle: 'Elle restera visible dans l\'historique, marquée comme annulée.',
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GroupeField(
              controller: controller,
              hint: 'Motif de l\'annulation',
              icon: Icons.edit_note_rounded,
              maxLength: 255,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SignmeSpacing.lg),
            SignmePrimaryButton(
              label: 'Annuler l\'entrée',
              enabled: controller.text.trim().isNotEmpty,
              onPressed: () => Navigator.pop(sheetContext, controller.text.trim()),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (motif == null || !mounted) return;

    try {
      await ref
          .read(mesGroupesRemoteDataSourceProvider)
          .annulerCash(groupe.uuid, m.id.replaceFirst('cash:', ''), motif);
      if (!mounted) return;
      refreshGroupe(ref, widget.uuid);
      AppSnackbar.success(context, 'Entrée annulée.');
    } catch (e) {
      if (mounted) AppSnackbar.error(context, messageFromError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupeAsync = ref.watch(groupeProvider(widget.uuid));

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          tooltip: 'Retour',
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.services),
        ),
      ),
      body: groupeAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
          children: const [SignmeSkeletonList(itemCount: 4, itemHeight: 110)],
        ),
        error: (e, _) => SignmeErrorState(
          title: 'Chargement impossible',
          message: messageFromError(e),
          onRetry: _actualiser,
        ),
        data: _contenu,
      ),
    );
  }

  Widget _contenu(GroupeEntity groupe) {
    final bottom = MediaQuery.of(context).padding.bottom + SignmeSpacing.xxxl;
    final responsable = groupe.estResponsable;

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: _actualiser,
      child: ListView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(SignmeSpacing.lg, 0, SignmeSpacing.lg, bottom),
        children: [
          Text(
            groupe.nom,
            style: SignmeTypography.displaySmall.copyWith(fontWeight: FontWeight.w900, height: 1.2),
          ),
          const SizedBox(height: SignmeSpacing.sm),
          Wrap(
            spacing: SignmeSpacing.sm,
            runSpacing: SignmeSpacing.sm,
            children: [
              _Puce(icon: Icons.badge_rounded, label: groupe.posteLabel, accent: true),
              if (groupe.nbMembres != null)
                _Puce(icon: Icons.groups_rounded, label: '${groupe.nbMembres} membre${groupe.nbMembres! > 1 ? 's' : ''}'),
              if (groupe.president != null) _Puce(icon: Icons.workspace_premium_rounded, label: groupe.president!),
              if (groupe.tresorier != null && groupe.tresorier != groupe.president)
                _Puce(icon: Icons.account_balance_wallet_rounded, label: groupe.tresorier!),
            ],
          ),
          const SizedBox(height: SignmeSpacing.lg),
          if (groupe.caisse != null)
            GroupeCaisseCard(
              caisse: groupe.caisse!,
              onEntreeCash: responsable ? () => _entreeCash(groupe) : null,
              onRetrait: responsable ? () => _retrait(groupe) : null,
            ),
          const SizedBox(height: SignmeSpacing.lg),
          SignmePrimaryButton(
            label: 'Faire un don au groupe',
            icon: Icons.volunteer_activism_rounded,
            onPressed: () => _contribuer(groupe),
          ),
          const SizedBox(height: SignmeSpacing.xl),
          _Onglets(
            index: _onglet,
            onChanged: (i) => setState(() => _onglet = i),
          ),
          const SizedBox(height: SignmeSpacing.lg),
          if (_onglet == 0) ..._communiques(groupe) else ..._historique(groupe),
        ],
      ),
    );
  }

  List<Widget> _communiques(GroupeEntity groupe) {
    final async = ref.watch(communiquesProvider(widget.uuid));

    return [
      if (groupe.estPresident) ...[
        SignmeSecondaryButton(
          label: 'Nouveau communiqué',
          icon: Icons.campaign_rounded,
          onPressed: () async {
            await context.push<void>('/services/groupes/${groupe.uuid}/communique');
            if (mounted) refreshGroupe(ref, widget.uuid);
          },
        ),
        const SizedBox(height: SignmeSpacing.lg),
      ],
      async.when(
        loading: () => const SignmeSkeletonList(itemCount: 2, itemHeight: 150),
        error: (e, _) => SignmeErrorState(
          title: 'Communiqués indisponibles',
          message: messageFromError(e),
          onRetry: () => ref.invalidate(communiquesProvider(widget.uuid)),
        ),
        data: (liste) => liste.isEmpty
            ? const SignmeEmptyState(
                icon: Icons.campaign_outlined,
                title: 'Aucun communiqué',
                message: 'Les annonces du groupe apparaîtront ici.',
              )
            : Column(
                children: [
                  for (final c in liste)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SignmeSpacing.md),
                      child: CommuniqueCard(
                        communique: c,
                        onTap: () => _ouvrirCommunique(groupe, c),
                        onContribuer: () => _contribuer(groupe, communique: c),
                      ),
                    ),
                ],
              ),
      ),
    ];
  }

  List<Widget> _historique(GroupeEntity groupe) {
    final state = ref.watch(mouvementsProvider(widget.uuid));

    if (state.isLoading && state.items.isEmpty) {
      return const [SignmeSkeletonList(itemCount: 5, itemHeight: 72)];
    }
    if (state.error != null && state.items.isEmpty) {
      return [
        SignmeErrorState(
          title: 'Historique indisponible',
          message: state.error!,
          onRetry: ref.read(mouvementsProvider(widget.uuid).notifier).refresh,
        ),
      ];
    }
    if (state.items.isEmpty) {
      return const [
        SignmeEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Aucun mouvement',
          message: 'Les entrées et sorties d\'argent du groupe apparaîtront ici.',
        ),
      ];
    }

    return [
      for (final m in state.items)
        Padding(
          padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
          child: MouvementTile(
            mouvement: m,
            onTap: groupe.estResponsable && m.estCash && !m.annule ? () => _annulerCash(groupe, m) : null,
          ),
        ),
      if (state.isLoadingMore)
        const Padding(
          padding: EdgeInsets.all(SignmeSpacing.lg),
          child: Center(child: CircularProgressIndicator(color: SignmeColors.primaryLight)),
        ),
      if (groupe.estResponsable)
        Padding(
          padding: const EdgeInsets.only(top: SignmeSpacing.sm),
          child: Text(
            'Touchez une entrée cash pour l\'annuler en cas d\'erreur.',
            textAlign: TextAlign.center,
            style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
          ),
        ),
    ];
  }
}

class _Puce extends StatelessWidget {
  const _Puce({required this.icon, required this.label, this.accent = false});

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final couleur = accent ? SignmeColors.primaryLight : SignmeColors.darkGray;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent ? SignmeColors.primaryLight.withValues(alpha: 0.1) : SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
        border: Border.all(color: accent ? SignmeColors.primaryLight.withValues(alpha: 0.3) : SignmeColors.lightGrayBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: couleur),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SignmeTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: couleur),
            ),
          ),
        ],
      ),
    );
  }
}

class _Onglets extends StatelessWidget {
  const _Onglets({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['Communiqués', 'Historique'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SignmeColors.accentSky.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: index == i,
                label: labels[i],
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: SignmeSpacing.animationFast,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: index == i ? SignmeColors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
                      boxShadow: index == i
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: Text(
                      labels[i],
                      style: SignmeTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: index == i ? SignmeColors.primaryLight : SignmeColors.darkGray,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
