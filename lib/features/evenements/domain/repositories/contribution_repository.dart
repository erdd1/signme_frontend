import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/contributions_remote_datasource.dart';
import '../entities/contribution_entity.dart';

/// Interface du paiement de contribution — même forme que
/// SignatureRepository, pour rester cohérent avec le flux de paiement
/// existant (initiate + polling du statut).
abstract class ContributionRepository {
  Future<ContributionEntity> initiate({
    required String evenementUuid,
    required int montant,
    String? note,
    required String paymentMethod,
    String? paymentOperator,
    String? paymentNumber,
    int? groupeId,
  });

  Future<ContributionEntity> getStatus(String contributionUuid);
}

class ContributionRepositoryImpl implements ContributionRepository {
  ContributionRepositoryImpl(this._remote);

  final ContributionsRemoteDataSource _remote;

  @override
  Future<ContributionEntity> initiate({
    required String evenementUuid,
    required int montant,
    String? note,
    required String paymentMethod,
    String? paymentOperator,
    String? paymentNumber,
    int? groupeId,
  }) async {
    final model = await _remote.initiate(
      evenementUuid: evenementUuid,
      montant: montant,
      note: note,
      paymentMethod: paymentMethod,
      paymentOperator: paymentOperator,
      paymentNumber: paymentNumber,
      groupeId: groupeId,
    );
    return model.toEntity();
  }

  @override
  Future<ContributionEntity> getStatus(String contributionUuid) async {
    final model = await _remote.getStatus(contributionUuid);
    return model.toEntity();
  }
}

final contributionsRemoteDataSourceProvider = Provider<ContributionsRemoteDataSource>(
  (ref) => ContributionsRemoteDataSource(ref.watch(dioProvider)),
);

final contributionRepositoryProvider = Provider<ContributionRepository>(
  (ref) => ContributionRepositoryImpl(ref.watch(contributionsRemoteDataSourceProvider)),
);
