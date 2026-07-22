import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/evenement_entity.dart';
import '../providers/evenements_provider.dart';
import '../widgets/evenement_gestion_card.dart';

/// Écran "Gérer les événements" — Pasteur/Secrétaire/Trésorier.
///
/// Liste distinctement les événements Actifs et Archivés, avec pour chacun
/// le montant total collecté et le nombre de membres ayant contribué.
class GestionEvenementsScreen extends ConsumerStatefulWidget {
  const GestionEvenementsScreen({super.key});

  @override
  ConsumerState<GestionEvenementsScreen> createState() => _GestionEvenementsScreenState();
}

class _GestionEvenementsScreenState extends ConsumerState<GestionEvenementsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).auth?.user;
    final canCreate = user != null && AppPermissions.canManageEvenements(user);

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: SignmeColors.black),
        actions: [
          if (canCreate)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: SignmeColors.primaryLight),
              tooltip: 'Nouvel événement',
              onPressed: () => context.push(AppRoutes.evenementCreate),
            ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: SignmeColors.primaryLight,
          unselectedLabelColor: SignmeColors.mediumGray,
          indicatorColor: SignmeColors.primaryLight,
          indicatorWeight: 3,
          labelStyle: SignmeTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: SignmeTypography.labelSmall.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'Actifs'),
            Tab(text: 'Archivés'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _EvenementsGestionList(statut: kEvenementsGestionActifs),
          _EvenementsGestionList(statut: kEvenementsGestionArchives),
        ],
      ),
    );
  }
}

class _EvenementsGestionList extends ConsumerWidget {
  const _EvenementsGestionList({required this.statut});
  final String statut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(evenementsGestionProvider(statut));

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () => ref.read(evenementsGestionProvider(statut).notifier).refresh(),
      child: SignmeAsyncValue<List<EvenementEntity>>(
        value: async,
        onRetry: () => ref.read(evenementsGestionProvider(statut).notifier).refresh(),
        emptyTitle: statut == kEvenementsGestionActifs ? 'Aucun événement actif' : 'Aucun événement archivé',
        emptyMessage: 'Les événements apparaîtront ici.',
        isEmpty: (list) => list.isEmpty,
        data: (evenements) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            SignmeSpacing.lg,
            SignmeSpacing.lg,
            SignmeSpacing.lg,
            120,
          ),
          itemCount: evenements.length,
          separatorBuilder: (_, __) => const SizedBox(height: SignmeSpacing.md),
          itemBuilder: (context, i) => EvenementGestionCard(evenement: evenements[i]),
        ),
      ),
    );
  }
}
