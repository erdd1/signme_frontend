import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/evenements/domain/entities/contribution_entity.dart';
import 'package:signme/features/evenements/domain/repositories/contribution_repository.dart';
import 'package:signme/features/evenements/presentation/providers/contribution_form_provider.dart';

class _FakeContributionRepository implements ContributionRepository {
  final List<Completer<ContributionEntity>> pendingInitiate = [];

  /// Destination de chaque paiement lancé (null = don libre, sans événement).
  final List<String?> initiatedFor = [];

  /// Derniers paramètres de paiement reçus par initiate().
  final List<({String method, String? operator, String? number})> initiated = [];

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
    initiated.add((method: paymentMethod, operator: paymentOperator, number: paymentNumber));
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

  group('paiement par carte', () {
    ContributionEntity pending({String? checkoutUrl}) => ContributionEntity(
          uuid: 'contrib-carte',
          montant: 1000,
          frais: 53,
          montantTotal: 1053,
          statut: 'pending',
          createdAt: DateTime.now(),
          checkoutUrl: checkoutUrl,
        );

    test('les frais de carte suivent le taux du serveur, pas la grille Mobile Money', () {
      final notifier = ContributionFormNotifier(_FakeContributionRepository());
      addTearDown(notifier.disposePoller);
      notifier.setMontant(1000);

      expect(notifier.state.frais, 100); // grille Mobile Money

      notifier
        ..setCardFeePercent(5)
        ..setPaymentMethod('card');

      expect(notifier.state.isCard, isTrue);
      expect(notifier.state.frais, 53); // 1000 / 0,95 = 1052,6 -> total 1053
      expect(notifier.state.total, 1053);
    });

    test('un paiement par carte n\'exige ni numéro ni opérateur et envoie la méthode card', () async {
      final repo = _FakeContributionRepository();
      final notifier = ContributionFormNotifier(repo);
      addTearDown(notifier.disposePoller);
      notifier
        ..setCardFeePercent(5)
        ..setPaymentMethod('card'); // aucun numéro saisi

      final done = notifier.effectuerPaiement('evenement-uuid');
      repo.pendingInitiate.single.complete(pending(checkoutUrl: 'https://checkout.test/pay/1'));

      expect(await done, isTrue);
      expect(repo.initiated.single, (method: 'card', operator: null, number: null));
      expect(notifier.state.checkoutUrl, 'https://checkout.test/pay/1');
    });

    test('le Mobile Money exige toujours un numéro valide', () async {
      final repo = _FakeContributionRepository();
      final notifier = ContributionFormNotifier(repo);
      addTearDown(notifier.disposePoller);

      expect(await notifier.effectuerPaiement('evenement-uuid'), isFalse);

      expect(notifier.state.error, 'Numéro invalide.');
      expect(repo.initiated, isEmpty);
    });

    test('sans page de paiement renvoyée, l\'erreur est affichée et rien n\'est suivi', () async {
      final repo = _FakeContributionRepository();
      final notifier = ContributionFormNotifier(repo);
      addTearDown(notifier.disposePoller);
      notifier
        ..setCardFeePercent(5)
        ..setPaymentMethod('card');

      final done = notifier.effectuerPaiement('evenement-uuid');
      repo.pendingInitiate.single.complete(pending()); // pas de checkoutUrl

      expect(await done, isFalse);
      expect(notifier.state.paymentStatus, 'failed');
      expect(notifier.state.checkoutUrl, isNull);
    });
  });
}
