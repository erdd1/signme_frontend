import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/evenements/domain/entities/contribution_entity.dart';
import 'package:signme/features/evenements/domain/repositories/contribution_repository.dart';
import 'package:signme/features/evenements/presentation/providers/contribution_form_provider.dart';

class _FakeContributionRepository implements ContributionRepository {
  final List<Completer<ContributionEntity>> pendingInitiate = [];

  /// Destination de chaque paiement lancé (null = don libre, sans événement).
  final List<String?> initiatedFor = [];

  @override
  Future<ContributionEntity> initiate({
    String? evenementUuid,
    required int montant,
    String? note,
    required String paymentMethod,
    String? paymentOperator,
    String? paymentNumber,
    int? groupeId,
  }) {
    initiatedFor.add(evenementUuid);
    final completer = Completer<ContributionEntity>();
    pendingInitiate.add(completer);
    return completer.future;
  }

  @override
  Future<ContributionEntity> getStatus(String contributionUuid) async =>
      ContributionEntity(
        uuid: contributionUuid,
        montant: 500,
        frais: 25,
        montantTotal: 525,
        statut: 'completed',
        createdAt: DateTime.now(),
      );
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

      // Opérateur + numéro valides : requis depuis la suppression du
      // paiement par carte (mobile money uniquement désormais).
      notifier.setOperator('ORANGE MONEY');
      notifier.setPhone('699112233');

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
          createdAt: DateTime.now(),
        ),
      );
      expect(await first, isTrue);
    },
  );

  group('destination du paiement', () {
    ContributionEntity pending() => ContributionEntity(
          uuid: 'contrib-1',
          montant: 500,
          frais: 25,
          montantTotal: 525,
          statut: 'pending',
          createdAt: DateTime.now(),
        );

    test('un don libre (sans événement) est envoyé sans uuid et remercie pour le don', () async {
      final repo = _FakeContributionRepository();
      final notifier = ContributionFormNotifier(repo);
      addTearDown(notifier.disposePoller);
      notifier.setPhone('699112233');

      final done = notifier.effectuerPaiement(null);
      repo.pendingInitiate.single.complete(pending());

      expect(await done, isTrue);
      expect(repo.initiatedFor, [null]);
      expect(notifier.state.paymentMessage, contains('votre don'));
    });

    test('une contribution à un événement garde son uuid et son message', () async {
      final repo = _FakeContributionRepository();
      final notifier = ContributionFormNotifier(repo);
      addTearDown(notifier.disposePoller);
      notifier.setPhone('699112233');

      final done = notifier.effectuerPaiement('evenement-uuid');
      repo.pendingInitiate.single.complete(pending());

      expect(await done, isTrue);
      expect(repo.initiatedFor, ['evenement-uuid']);
      expect(notifier.state.paymentMessage, contains('votre contribution'));
    });
  });
}
