import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/evenements/domain/entities/contribution_entity.dart';
import 'package:signme/features/evenements/domain/repositories/contribution_repository.dart';
import 'package:signme/features/evenements/presentation/providers/contribution_form_provider.dart';

class _FakeContributionRepository implements ContributionRepository {
  final List<Completer<ContributionEntity>> pendingInitiate = [];

  @override
  Future<ContributionEntity> initiate({
    required String evenementUuid,
    required int montant,
    String? note,
    required String paymentMethod,
    String? paymentOperator,
    String? paymentNumber,
    int? groupeId,
  }) {
    final completer = Completer<ContributionEntity>();
    pendingInitiate.add(completer);
    return completer.future;
  }

  @override
  Future<ContributionEntity> getStatus(String contributionUuid) =>
      throw UnimplementedError();
}

void main() {
  test(
    'effectuerPaiement() : un double-appel (double-tap trop rapide pour que '
    "le bouton n'ait eu le temps de se désactiver) ne déclenche qu'un seul "
    'paiement',
    () async {
      final repo = _FakeContributionRepository();
      final notifier = ContributionFormNotifier(repo);
      addTearDown(notifier.disposePoller);

      notifier.setPaymentMethod('card'); // évite la validation du numéro

      final first = notifier.effectuerPaiement('evenement-uuid');
      final second = notifier.effectuerPaiement('evenement-uuid');

      expect(await second, isFalse);
      expect(repo.pendingInitiate.length, 1);

      repo.pendingInitiate.single.complete(
        ContributionEntity(
          uuid: 'contrib-1',
          montant: 500,
          frais: 25,
          montantTotal: 525,
          statut: 'pending',
          authorizationUrl: 'https://pay.example/checkout',
          createdAt: DateTime.now(),
        ),
      );
      expect(await first, isTrue);
    },
  );
}
