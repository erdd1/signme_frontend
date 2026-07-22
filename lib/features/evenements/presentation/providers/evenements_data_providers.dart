import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/evenements_remote_datasource.dart';
import '../../data/datasources/evenements_local_datasource.dart';

final evenementsRemoteDataSourceProvider = Provider<EvenementsRemoteDataSource>(
  (ref) => EvenementsRemoteDataSource(ref.watch(dioProvider)),
);

/// Datasource local (Isar) — cache Offline-First.
final evenementsLocalDataSourceProvider = Provider<EvenementsLocalDataSource>(
  (_) => EvenementsLocalDataSource(),
);
