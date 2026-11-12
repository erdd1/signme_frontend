import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/entities/chant_hub_entities.dart';
import '../providers/chants_provider.dart';
import '../widgets/chant_reference_tile.dart';

/// Liste complète : mes favoris, mes chants récents ou les chants du moment.
/// [type] : favoris | historique | tendances. Plein écran, hors coquille.
class ChantsListeScreen extends ConsumerWidget {
  const ChantsListeScreen({super.key, required this.type});

  final String type;

  String get _titre => switch (type) {
        'favoris' => 'Mes favoris',
        'tendances' => 'Populaires cette semaine',
        _ => 'Récemment',
      };

  AutoDisposeFutureProvider<List<ChantReferenceEntity>> get _provider => switch (type) {
        'favoris' => chantsFavorisProvider,
        'tendances' => chantsTendancesProvider,
        _ => chantsHistoriqueProvider,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_provider);
    final bottom = MediaQuery.of(context).padding.bottom + SignmeSpacing.xl;

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          tooltip: 'Retour',
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.chants),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(SignmeSpacing.lg, 0, SignmeSpacing.lg, SignmeSpacing.lg),
            child: Text(_titre, style: SignmeTypography.displaySmall.copyWith(fontWeight: FontWeight.w900, height: 1.2)),
          ),
          Expanded(
            child: async.when(
              loading: () => ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                children: const [SignmeSkeletonList(itemCount: 6, itemHeight: 84)],
              ),
              error: (e, _) => SignmeErrorState(
                title: 'Chargement impossible',
                message: messageFromError(e),
                icon: e is NetworkException ? Icons.wifi_off_rounded : Icons.error_outline,
                onRetry: () => ref.invalidate(_provider),
              ),
              data: (chants) => chants.isEmpty
                  ? const SignmeEmptyState(
                      icon: Icons.library_music_outlined,
                      title: 'Rien ici pour le moment',
                      message: 'Les chants que vous regardez apparaîtront ici.',
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(SignmeSpacing.lg, 0, SignmeSpacing.lg, bottom),
                      itemCount: chants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: SignmeSpacing.md),
                      itemBuilder: (context, i) {
                        final c = chants[i];
                        final tuile = ChantReferenceTile(
                          chant: c,
                          onTap: () async {
                            await context.pushNamed('chant-detail', extra: OuvrirReference(c.uuid, titre: c.titre));
                            if (context.mounted) rafraichirAccueilChants(ref);
                          },
                        );

                        // Mon historique : glisser pour retirer un chant.
                        if (type != 'historique') return tuile;
                        return Dismissible(
                          key: ValueKey('historique-${c.uuid}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: SignmeSpacing.lg),
                            decoration: BoxDecoration(
                              color: SignmeColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: SignmeColors.error),
                          ),
                          onDismissed: (_) async {
                            try {
                              await ref.read(chantsRemoteDataSourceProvider).retirerDeLHistorique(c.uuid);
                            } finally {
                              ref.invalidate(chantsHistoriqueProvider);
                            }
                          },
                          child: tuile,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
