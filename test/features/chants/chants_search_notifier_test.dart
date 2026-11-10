import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/chants/data/datasources/chants_remote_datasource.dart';
import 'package:signme/features/chants/domain/entities/chant_entity.dart';
import 'package:signme/features/chants/presentation/providers/chants_provider.dart';

/// Ne touche jamais au réseau : chaque recherche est mise en attente et
/// résolue manuellement par le test.
class _FakeChantsRemoteDataSource extends ChantsRemoteDataSource {
  _FakeChantsRemoteDataSource() : super(Dio());

  final List<String> queries = [];
  final List<Completer<List<ChantSummaryEntity>>> pending = [];

  @override
  Future<List<ChantSummaryEntity>> search(String query, {CancelToken? cancelToken}) {
    queries.add(query);
    final completer = Completer<List<ChantSummaryEntity>>();
    pending.add(completer);
    return completer.future;
  }
}

ChantSummaryEntity _chant(int id, String title) => ChantSummaryEntity(
      id: id,
      title: title,
      artist: 'Artiste',
      excerpt: const [],
      versions: const [],
    );

const _afterDebounce = Duration(milliseconds: 450);

void main() {
  test('moins de 2 caractères : aucune requête, état inactif', () async {
    final remote = _FakeChantsRemoteDataSource();
    final notifier = ChantsSearchNotifier(remote);

    notifier.onQueryChanged('a');
    await Future<void>.delayed(_afterDebounce);

    expect(remote.queries, isEmpty);
    expect(notifier.state.isIdle, isTrue);
    notifier.dispose();
  });

  test('la saisie rapide est regroupée : une seule requête avec le dernier texte', () async {
    final remote = _FakeChantsRemoteDataSource();
    final notifier = ChantsSearchNotifier(remote);

    notifier
      ..onQueryChanged('gr')
      ..onQueryChanged('gra')
      ..onQueryChanged('grace');
    expect(notifier.state.result.isLoading, isTrue);
    await Future<void>.delayed(_afterDebounce);

    expect(remote.queries, ['grace']);
    remote.pending.single.complete([_chant(1, 'Grâce infinie')]);
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.result.value, hasLength(1));
    notifier.dispose();
  });

  test('une réponse obsolète n\'écrase pas une recherche plus récente', () async {
    final remote = _FakeChantsRemoteDataSource();
    final notifier = ChantsSearchNotifier(remote);

    notifier.onQueryChanged('grace');
    await Future<void>.delayed(_afterDebounce);
    notifier.onQueryChanged('alleluia');
    await Future<void>.delayed(_afterDebounce);
    expect(remote.queries, ['grace', 'alleluia']);

    remote.pending[1].complete([_chant(2, 'Alléluia')]);
    await Future<void>.delayed(Duration.zero);
    remote.pending[0].complete([_chant(1, 'Grâce infinie')]);
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.query, 'alleluia');
    expect(notifier.state.result.value!.single.title, 'Alléluia');
    notifier.dispose();
  });

  test('une erreur réseau est exposée puis « Réessayer » relance la recherche', () async {
    final remote = _FakeChantsRemoteDataSource();
    final notifier = ChantsSearchNotifier(remote);

    notifier.onQueryChanged('grace');
    await Future<void>.delayed(_afterDebounce);
    remote.pending.single.completeError(Exception('hors ligne'));
    await Future<void>.delayed(Duration.zero);
    expect(notifier.state.result, isA<AsyncError<List<ChantSummaryEntity>>>());

    notifier.retry();
    expect(notifier.state.result.isLoading, isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(remote.queries, ['grace', 'grace']);
    notifier.dispose();
  });

  test('effacer le texte revient à l\'état inactif', () async {
    final remote = _FakeChantsRemoteDataSource();
    final notifier = ChantsSearchNotifier(remote);

    notifier.onQueryChanged('grace');
    notifier.onQueryChanged('');

    expect(notifier.state.isIdle, isTrue);
    await Future<void>.delayed(_afterDebounce);
    expect(remote.queries, isEmpty);
    notifier.dispose();
  });

  group('ChantDetailEntity', () {
    test('parse les sections, versions et la source', () {
      final chant = ChantDetailEntity.fromJson({
        'id': 10,
        'title': 'Grâce Infinie',
        'artist': 'Collectif',
        'album': null,
        'duration': 316,
        'sections': [
          {'type': 'strophe', 'lines': ['A', 'B']},
          {'type': 'refrain', 'lines': ['C']},
        ],
        'versions': [
          {'id': 10, 'artist': 'Collectif', 'album': null, 'duration': 316},
        ],
        'source': {'nom': 'LRCLIB', 'url': 'https://lrclib.net'},
      });

      expect(chant.sections.map((s) => s.type),
          [LyricsSectionType.strophe, LyricsSectionType.refrain]);
      expect(chant.plainText, 'A\nB\n\nC');
      expect(chant.sourceName, 'LRCLIB');
      expect(chant.versions.single.id, 10);
    });

    test('tolère des champs manquants sans lever d\'exception', () {
      final chant = ChantDetailEntity.fromJson({});

      expect(chant.sections, isEmpty);
      expect(chant.title, '');
      expect(chant.sourceName, '');
    });
  });
}
