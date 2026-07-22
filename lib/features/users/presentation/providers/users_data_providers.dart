import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/users_remote_datasource.dart';

final usersRemoteDataSourceProvider = Provider<UsersRemoteDataSource>(
  (ref) => UsersRemoteDataSource(ref.watch(dioProvider)),
);
