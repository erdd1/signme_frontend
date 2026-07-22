import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/support_remote_datasource.dart';

final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource>(
  (ref) => SupportRemoteDataSource(ref.watch(dioProvider)),
);
