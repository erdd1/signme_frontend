import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/contributions_local_datasource.dart';
import '../../data/datasources/contributions_remote_datasource.dart';

/// Provider du datasource remote contributions — partagé par l'ancien écran
/// (contribution_form) et le nouveau tableau de bord (dashboard).
final contributionsRemoteForTreasuryProvider = Provider<ContributionsRemoteDataSource>(
  (ref) => ContributionsRemoteDataSource(ref.watch(dioProvider)),
);

/// Provider du datasource local (cache Isar) — conservé pour le formulaire
/// de contribution (contribution_form_provider) qui en a encore besoin.
final contributionsLocalDataSourceProvider = Provider<ContributionsLocalDataSource>(
  (_) => ContributionsLocalDataSource(),
);
