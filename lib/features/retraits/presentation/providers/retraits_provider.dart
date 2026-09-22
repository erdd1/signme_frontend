import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/retraits_remote_datasource.dart';
import '../../domain/entities/retrait_beneficiaire_entity.dart';

final retraitsRemoteDataSourceProvider = Provider<RetraitsRemoteDataSource>(
  (ref) => RetraitsRemoteDataSource(ref.watch(dioProvider)),
);

/// Solde interne disponible (calculé côté serveur — jamais lu depuis
/// NotchPay::Balance, global à toute la plateforme).
final retraitSoldeProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(retraitsRemoteDataSourceProvider).fetchSolde();
});

/// Compte de retrait actif de l'utilisateur (null si jamais enregistré).
final retraitBeneficiaireProvider = FutureProvider.autoDispose<RetraitBeneficiaireEntity?>((ref) {
  return ref.watch(retraitsRemoteDataSourceProvider).fetchBeneficiaire();
});
