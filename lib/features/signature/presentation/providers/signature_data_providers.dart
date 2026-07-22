import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/signature_local_datasource.dart';
import '../../data/datasources/signature_remote_datasource.dart';

final signatureRemoteDataSourceProvider = Provider<SignatureRemoteDataSource>(
  (ref) => SignatureRemoteDataSource(ref.watch(dioProvider)),
);

final signatureLocalDataSourceProvider = Provider<SignatureLocalDataSource>(
  (_) => SignatureLocalDataSource(),
);