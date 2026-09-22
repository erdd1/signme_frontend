import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../signature/presentation/providers/signature_data_providers.dart';
import '../../domain/entities/historique_signatures_entity.dart';
import '../../data/models/historique_signatures_model.dart';

/// Notifier — Historique des Signatures (en présentiel), Offline-First.
///
/// Filtré uniquement par [_year] (seule dimension réellement utilisée par
/// l'écran — le statut est toujours "completed") : une `String` comme clé de
/// `.family`, contrairement à une `Map`, a une égalité par valeur fiable en
/// Dart, ce qui permet à [historiqueSignaturesBootstrapProvider] de
/// précharger exactement l'instance que l'écran lira ensuite.
///
/// 1. Affiche immédiatement le cache Isar (s'il existe).
/// 2. Rafraîchit depuis l'API en arrière-plan.
/// 3. En cas d'échec réseau, garde les données déjà affichées (jamais de
///    retour à un état "loading" vide une fois qu'on a des données).
class HistoriqueSignaturesNotifier
    extends StateNotifier<AsyncValue<List<HistoriqueSignaturesEntity>>> {
  HistoriqueSignaturesNotifier(this._ref, this._year)
      : super(const AsyncLoading()) {
    _loadFromCacheThenRefresh();
  }

  final Ref _ref;
  final String _year;

  Map<String, dynamic> get _cacheFilters => {'year': _year, 'status': 'completed'};

  Future<void> _loadFromCacheThenRefresh() async {
    final local = _ref.read(signatureLocalDataSourceProvider);
    final cached = await local.getHistoriqueSignatures(_cacheFilters);
    if (cached != null && mounted) {
      state = AsyncData(_toEntities(cached));
    }
    await refresh();
  }

  List<HistoriqueSignaturesEntity> _toEntities(List<Map<String, dynamic>> raw) {
    return raw
        .map((s) => HistoriqueSignaturesModel.fromJson(s).toEntity())
        .toList();
  }

  /// Rafraîchit depuis l'API et persiste en cache Isar. Parcourt TOUTES les
  /// pages (chaque requête bornée à 100 lignes) : un ancien actif peut avoir
  /// signé bien plus de 20 cartes sur une année, il ne faut jamais en perdre
  /// silencieusement au-delà de la première page.
  Future<void> refresh() async {
    final isOnline = await _ref.read(connectivityServiceProvider).isOnline;
    if (!isOnline) return;

    try {
      final dio = _ref.read(dioProvider);
      final queryParams = <String, String>{
        'status': 'completed',
        'year': _year,
      };

      final raw = <Map<String, dynamic>>[];
      var page = 1;
      while (true) {
        final response = await dio.get(
          '/signatures/historique-signatures',
          queryParameters: {...queryParams, 'page': '$page', 'per_page': '100'},
        );

        if (response.statusCode != 200) {
          throw DioException(requestOptions: response.requestOptions);
        }

        raw.addAll(((response.data['data'] as List?) ?? []).cast<Map<String, dynamic>>());

        final pagination = response.data['pagination'] as Map<String, dynamic>?;
        final currentPage = (pagination?['current_page'] as num?)?.toInt() ?? page;
        final lastPage = (pagination?['last_page'] as num?)?.toInt() ?? page;
        if (currentPage >= lastPage) break;
        page++;
      }

      final local = _ref.read(signatureLocalDataSourceProvider);
      await local.saveHistoriqueSignatures(_cacheFilters, raw);

      if (mounted) state = AsyncData(_toEntities(raw));
    } catch (e, st) {
      // Réseau en échec : on garde les données déjà affichées (cache ou
      // précédent succès). On ne propage l'erreur que si on n'a vraiment
      // rien à montrer.
      if (mounted && !state.hasValue) {
        state = AsyncError(e, st);
      }
    }
  }
}

final historiqueSignaturesProvider = StateNotifierProvider.family<
    HistoriqueSignaturesNotifier,
    AsyncValue<List<HistoriqueSignaturesEntity>>,
    String>(
  (ref, year) => HistoriqueSignaturesNotifier(ref, year),
);

/// Précharge l'historique des signatures de l'année courante au login — mêmes
/// filtres que ceux préchargés par [SyncService] au splash — pour que
/// l'écran n'affiche jamais le moindre flash de chargement, même à la toute
/// première ouverture.
final historiqueSignaturesBootstrapProvider = Provider<void>((ref) {
  ref.keepAlive();
  ref.listen<bool>(
    authNotifierProvider.select((s) => s.isInitialized && s.isAuthenticated),
    (wasAuthenticated, isAuthenticated) {
      if (isAuthenticated) {
        final year = DateTime.now().year.toString();
        Future<void>.microtask(
          () => ref.read(historiqueSignaturesProvider(year).notifier).refresh(),
        );
      }
    },
    fireImmediately: true,
  );
});
