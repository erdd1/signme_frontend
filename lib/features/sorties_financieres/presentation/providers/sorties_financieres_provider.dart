import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/sorties_remote_datasource.dart';

final sortiesRemoteDataSourceProvider = Provider<SortiesRemoteDataSource>(
  (ref) => SortiesRemoteDataSource(ref.watch(dioProvider)),
);
