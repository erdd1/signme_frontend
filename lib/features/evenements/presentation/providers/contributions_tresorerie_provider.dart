import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/contributions_local_datasource.dart';
import '../../data/datasources/contributions_remote_datasource.dart';
import '../../data/models/contribution_model.dart';
import '../../domain/entities/contribution_entity.dart';
import 'cache_first_list_notifier.dart';

final contributionsRemoteForTreasuryProvider = Provider<ContributionsRemoteDataSource>(
  (ref) => ContributionsRemoteDataSource(ref.watch(dioProvider)),
);

final contributionsLocalDataSourceProvider = Provider<ContributionsLocalDataSource>(
  (_) => ContributionsLocalDataSource(),
);

/// Onglet drawer "Contributions événement" — toutes les contributions de
/// l'église (pasteur/secrétaire/trésorier). Offline-first : affiche le
/// cache Isar puis rafraîchit en arrière-plan sans jamais repasser par un
/// état vide/"loading".
final contributionsTreasuryProvider = StateNotifierProvider<
    CacheFirstListNotifier<ContributionEntity>,
    AsyncValue<List<ContributionEntity>>>((ref) {
  final remote = ref.watch(contributionsRemoteForTreasuryProvider);
  final local = ref.watch(contributionsLocalDataSourceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);

  return CacheFirstListNotifier<ContributionEntity>(
    readCache: local.getTreasury,
    fetchAndCache: () async {
      final raw = await remote.listAllForTreasury();
      await local.saveTreasury(raw);
      return raw.map(ContributionModel.fromJson).map((m) => m.toEntity()).toList();
    },
    isOnline: () => connectivity.isOnline,
  );
});

/// Précharge "Contributions événement" au login (utilisateurs autorisés).
final contributionsTreasuryBootstrapProvider = Provider<void>((ref) {
  ref.keepAlive();
  ref.listen<AuthState>(
    authNotifierProvider,
    (previous, next) {
      final user = next.auth?.user;
      final canView = next.isInitialized &&
          next.isAuthenticated &&
          user != null &&
          AppPermissions.canViewContributionsEvenement(user);

      if (canView) {
        Future<void>.microtask(
          () => ref.read(contributionsTreasuryProvider.notifier).refresh(),
        );
      }
    },
    fireImmediately: true,
  );
});
