import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/utils/pending_refresh_scheduler.dart';
import '../../domain/entities/historique_personnel_entity.dart';
import '../../data/models/historique_personnel_model.dart';
import '../../data/datasources/historique_perso_local_datasource.dart';

/// Récupère TOUTES les pages d'un endpoint d'historique — chaque requête
/// HTTP reste bornée à 100 lignes, quel que soit le volume total accumulé
/// par l'utilisateur au fil des années (jamais "tout d'un coup").
Future<List<Map<String, dynamic>>> _fetchAllPages(
  Dio dio,
  String path,
  Map<String, String> baseParams,
) async {
  final all = <Map<String, dynamic>>[];
  var page = 1;
  while (true) {
    final resp = await dio.get(path, queryParameters: {
      ...baseParams,
      'page': '$page',
      'per_page': '100',
    });
    if (resp.statusCode != 200) break;
    final data = (resp.data['data'] as List?) ?? [];
    all.addAll(data.cast<Map<String, dynamic>>());

    final pagination = resp.data['pagination'] as Map<String, dynamic>?;
    final currentPage = (pagination?['current_page'] as num?)?.toInt() ?? page;
    final lastPage = (pagination?['last_page'] as num?)?.toInt() ?? page;
    if (currentPage >= lastPage) break;
    page++;
  }
  return all;
}

// ─── Provider datasource locale ───────────────────────────────────────────────
final historiquePersoLocalDataSourceProvider =
    Provider<HistoriquePersoLocalDataSource>(
  (_) => HistoriquePersoLocalDataSource(),
);

/// Notifier combiné — Historique Personnel (distance + présentiel), Offline-First.
///
/// Filtré uniquement par [_year] (seule dimension réellement utilisée par
/// l'écran) : une `String` comme clé de `.family`, contrairement à une
/// `Map`, a une égalité par valeur fiable en Dart, ce qui permet à
/// [historiquePersonnelBootstrapProvider] de précharger exactement
/// l'instance que l'écran lira ensuite.
///
/// Tous les statuts sont remontés (pending/completed/failed), pas seulement
/// "completed" : dès l'envoi d'un paiement à distance, l'utilisateur doit
/// voir sa signature apparaître "en cours de traitement", puis passer à
/// "payé" ou "paiement échoué" une fois le webhook de paiement traité côté
/// backend — [_pendingScheduler] relance un [refresh] léger tant qu'une
/// entrée reste en attente, pour donner cet effet temps réel sans dépendre
/// d'un canal WebSocket dédié par paiement (voir sa doc pour le détail).
///
/// 1. Affiche immédiatement le cache Isar (s'il existe).
/// 2. Rafraîchit depuis l'API (les deux endpoints en parallèle) en arrière-plan.
/// 3. En cas d'échec réseau, garde les données déjà affichées.
class HistoriquePersonnelCombinedNotifier
    extends StateNotifier<AsyncValue<List<HistoriquePersonnelEntity>>> {
  HistoriquePersonnelCombinedNotifier(this._ref, this._year)
      : super(const AsyncLoading()) {
    _pendingScheduler = PendingRefreshScheduler(refresh: refresh);
    _loadFromCacheThenRefresh();
  }

  final Ref _ref;
  final String _year;
  late final PendingRefreshScheduler _pendingScheduler;

  Map<String, dynamic> get _cacheFilters => {'year': _year};

  List<HistoriquePersonnelEntity> _toEntities(List<Map<String, dynamic>> raw) {
    final entities = raw.map(_mapRaw).toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entities;
  }

  HistoriquePersonnelEntity _mapRaw(Map<String, dynamic> s) {
    final model = HistoriquePersonnelModel.fromJson(s);
    if (s['signatureType'] != 'presentiel') return model.toEntity();

    final signataireName = s['ancienNom']?.toString() ?? 'Signataire inconnu';
    final ancienMap = s['ancien'] as Map<String, dynamic>?;
    final rawRole = ancienMap?['role']?.toString() ?? 'ancien';
    final roleLabel = rawRole == 'pasteur' ? 'Pasteur' : 'Ancien de service';

    return HistoriquePersonnelEntity(
      id:                 model.id,
      userId:             model.userId,
      nomUtilisateur:     model.nomUtilisateur,
      month:              model.month,
      year:               model.year,
      status:             model.status,
      amount:             model.amount,
      fees:               model.fees,
      signatureType:      'presentiel',
      paymentMethod:      null,
      paymentPhoneNumber: null,
      createdAt:          model.createdAt,
      completedAt:        model.completedAt,
      errorMessage:       null,
      signataireName:     signataireName,
      signatairerole:     roleLabel,
    );
  }

  Future<void> _loadFromCacheThenRefresh() async {
    final local = _ref.read(historiquePersoLocalDataSourceProvider);
    final cached = await local.get(_cacheFilters);
    if (cached != null && mounted) {
      final entities = _toEntities(cached);
      state = AsyncData(entities);
      _pendingScheduler.scheduleIfNeeded(entities.any((e) => e.isPending));
    }
    await refresh();
  }

  /// Rafraîchit depuis l'API (distance + présentiel) et persiste en cache Isar.
  Future<void> refresh() async {
    final isOnline = await _ref.read(connectivityServiceProvider).isOnline;
    if (!isOnline) return;

    try {
      final dio = _ref.read(dioProvider);
      final queryParams = <String, String>{'year': _year};

      final results = await Future.wait([
        _fetchAllPages(dio, '/signatures/historique-personnel', queryParams),
        _fetchAllPages(dio, '/signatures/historique-personnel-presentiel', queryParams),
      ]);

      final rawForCache = <Map<String, dynamic>>[
        ...results[0],
        ...results[1].map((s) => {...s, 'signatureType': 'presentiel'}),
      ];

      final local = _ref.read(historiquePersoLocalDataSourceProvider);
      await local.save(_cacheFilters, rawForCache);

      final entities = _toEntities(rawForCache);
      if (mounted) state = AsyncData(entities);
      _pendingScheduler.scheduleIfNeeded(entities.any((e) => e.isPending));
    } catch (e, st) {
      // Réseau en échec : on garde les données déjà affichées (cache ou
      // précédent succès). On ne propage l'erreur que si on n'a vraiment
      // rien à montrer.
      if (mounted && !state.hasValue) {
        state = AsyncError(e, st);
      }
    }
  }

  @override
  void dispose() {
    _pendingScheduler.dispose();
    super.dispose();
  }
}

final historiquePersonnelCombinedProvider = StateNotifierProvider.family<
    HistoriquePersonnelCombinedNotifier,
    AsyncValue<List<HistoriquePersonnelEntity>>,
    String>(
  (ref, year) => HistoriquePersonnelCombinedNotifier(ref, year),
);

/// Précharge l'historique personnel de l'année courante au login — même
/// filtres que ceux préchargés par [SyncService] au splash — pour que
/// l'écran n'affiche jamais le moindre flash de chargement, même à la toute
/// première ouverture.
final historiquePersonnelBootstrapProvider = Provider<void>((ref) {
  ref.keepAlive();
  ref.listen<bool>(
    authNotifierProvider.select((s) => s.isInitialized && s.isAuthenticated),
    (wasAuthenticated, isAuthenticated) {
      if (isAuthenticated) {
        final year = DateTime.now().year.toString();
        Future<void>.microtask(
          () => ref.read(historiquePersonnelCombinedProvider(year).notifier).refresh(),
        );
      }
    },
    fireImmediately: true,
  );
});
