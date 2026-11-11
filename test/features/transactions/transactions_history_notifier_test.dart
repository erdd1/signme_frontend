import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/transactions/data/datasources/transactions_remote_datasource.dart';
import 'package:signme/features/transactions/domain/entities/transaction_entity.dart';
import 'package:signme/features/transactions/presentation/providers/transactions_provider.dart';

class _Call {
  _Call(this.page, this.query, this.statut, this.type, this.completer);

  final int page;
  final String? query;
  final String? statut;
  final String? type;
  final Completer<TransactionsPage> completer;
}

/// Ne touche jamais au réseau : chaque appel est mis en attente et résolu
/// par le test, dans l'ordre voulu.
class _FakeDataSource extends TransactionsRemoteDataSource {
  _FakeDataSource() : super(Dio());

  final List<_Call> calls = [];

  @override
  Future<TransactionsPage> list({
    int page = 1,
    int perPage = 20,
    String? query,
    String? statut,
    String? type,
    CancelToken? cancelToken,
  }) {
    final call = _Call(page, query, statut, type, Completer<TransactionsPage>());
    calls.add(call);
    return call.completer.future;
  }
}

TransactionEntity _t(String id) => TransactionEntity(
      id: id,
      type: TransactionType.don,
      motif: 'Don à l\'église',
      details: const [],
      montant: 1000,
      frais: 51,
      montantTotal: 1051,
      status: TransactionStatus.completed,
      paymentMethod: 'card',
      paymentLabel: 'Carte bancaire',
      createdAt: DateTime(2026, 11, 11, 2, 14),
    );

TransactionsPage _page(List<String> ids, {int current = 1, int last = 1}) =>
    TransactionsPage(items: ids.map(_t).toList(), currentPage: current, lastPage: last);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeDataSource remote;
  late TransactionsHistoryNotifier notifier;

  setUp(() {
    remote = _FakeDataSource();
    notifier = TransactionsHistoryNotifier(remote);
  });

  tearDown(() => notifier.dispose());

  test('charge la première page dès l\'ouverture', () async {
    expect(notifier.state.isLoading, isTrue);
    expect(remote.calls.single.page, 1);

    remote.calls.single.completer.complete(_page(['a', 'b'], last: 2));
    await _settle();

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.items.map((t) => t.id), ['a', 'b']);
    expect(notifier.state.hasMore, isTrue);
  });

  test('loadMore ajoute la page suivante, une seule requête à la fois', () async {
    remote.calls.single.completer.complete(_page(['a'], last: 2));
    await _settle();

    final first = notifier.loadMore();
    final second = notifier.loadMore(); // ignorée : un chargement est déjà en cours
    expect(remote.calls, hasLength(2));
    expect(remote.calls.last.page, 2);

    remote.calls.last.completer.complete(_page(['b'], current: 2, last: 2));
    await first;
    await second;

    expect(notifier.state.items.map((t) => t.id), ['a', 'b']);
    expect(notifier.state.hasMore, isFalse);

    await notifier.loadMore(); // plus de page : rien
    expect(remote.calls, hasLength(2));
  });

  test('un filtre relance la recherche depuis la première page', () async {
    remote.calls.single.completer.complete(_page(['a'], last: 3));
    await _settle();

    notifier.setStatut(TransactionStatus.failed);

    expect(notifier.state.isLoading, isTrue);
    expect(remote.calls.last.page, 1);
    expect(remote.calls.last.statut, 'failed');

    remote.calls.last.completer.complete(_page(['x']));
    await _settle();
    expect(notifier.state.items.map((t) => t.id), ['x']);

    notifier.setType(TransactionType.don);
    expect(remote.calls.last.statut, 'failed');
    expect(remote.calls.last.type, 'don');

    notifier.clearFilters();
    expect(remote.calls.last.statut, isNull);
    expect(remote.calls.last.type, isNull);
  });

  test('la saisie rapide est regroupée en une seule requête', () async {
    remote.calls.single.completer.complete(_page(['a']));
    await _settle();

    notifier
      ..setQuery('d')
      ..setQuery('do')
      ..setQuery('don');
    await Future<void>.delayed(const Duration(milliseconds: 450));

    expect(remote.calls, hasLength(2));
    expect(remote.calls.last.query, 'don');
  });

  test('une réponse obsolète n\'écrase pas une recherche plus récente', () async {
    final first = remote.calls.single;
    notifier.setStatut(TransactionStatus.completed); // nouvelle requête
    final second = remote.calls.last;

    second.completer.complete(_page(['recent']));
    await _settle();
    first.completer.complete(_page(['obsolete']));
    await _settle();

    expect(notifier.state.items.map((t) => t.id), ['recent']);
  });

  test('une erreur au premier chargement est exposée, refresh relance', () async {
    remote.calls.single.completer.completeError(Exception('hors ligne'));
    await _settle();

    expect(notifier.state.error, isNotNull);
    expect(notifier.state.items, isEmpty);

    final refresh = notifier.refresh();
    expect(notifier.state.error, isNull);
    remote.calls.last.completer.complete(_page(['a']));
    await refresh;

    expect(notifier.state.items, hasLength(1));
  });

  test('une erreur de pagination garde les transactions déjà affichées', () async {
    remote.calls.single.completer.complete(_page(['a'], last: 2));
    await _settle();

    final more = notifier.loadMore();
    remote.calls.last.completer.completeError(Exception('coupure'));
    await more;

    expect(notifier.state.items.map((t) => t.id), ['a']);
    expect(notifier.state.error, isNotNull);
    expect(notifier.state.isLoadingMore, isFalse);
  });
}
