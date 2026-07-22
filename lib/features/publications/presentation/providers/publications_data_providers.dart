import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/publications_remote_datasource.dart';
import '../../data/datasources/publications_local_datasource.dart';

/// Filtre type : '' | 'annonce' | 'meditation'
final publicationTypeFilterProvider = StateProvider<String>((ref) => '');

final publicationsRemoteDataSourceProvider =
    Provider<PublicationsRemoteDataSource>(
  (ref) => PublicationsRemoteDataSource(ref.watch(dioProvider)),
);

/// Datasource local (Isar) — cache Offline-First.
final publicationsLocalDataSourceProvider =
    Provider<PublicationsLocalDataSource>(
  (_) => PublicationsLocalDataSource(),
);

/// Filtres partagés liste publications (type, pagination).
final publicationFiltersProvider = Provider<Map<String, dynamic>>((ref) {
  final type = ref.watch(publicationTypeFilterProvider);
  return {
    'type': type,
    'per_page': 20,
  };
});
