import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/finances_remote_datasource.dart';
import '../../data/datasources/finances_local_datasource.dart';

final financesRemoteDataSourceProvider = Provider<FinancesRemoteDataSource>(
  (ref) => FinancesRemoteDataSource(ref.watch(dioProvider)),
);

final financesLocalDataSourceProvider = Provider<FinancesLocalDataSource>(
  (_) => FinancesLocalDataSource(),
);
