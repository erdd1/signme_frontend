import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';
import '../utils/app_logger.dart';
import '../utils/default_historique_filters.dart';
import '../../features/publications/data/datasources/publications_remote_datasource.dart';
import '../../features/publications/data/datasources/publications_local_datasource.dart';
import '../../features/badge/data/datasources/badge_remote_datasource.dart';
import '../../features/badge/data/datasources/badge_local_datasource.dart';
import '../../features/signature/data/datasources/signature_remote_datasource.dart';
import '../../features/signature/data/datasources/signature_local_datasource.dart';
import '../../features/historique_personnel/data/datasources/historique_perso_local_datasource.dart';
import '../../features/finances/data/datasources/finances_remote_datasource.dart';
import '../../features/finances/data/datasources/finances_local_datasource.dart';
import '../../features/rapports/data/datasources/rapport_secretaire_remote_datasource.dart';
import '../../features/rapports/data/datasources/rapport_secretaire_local_datasource.dart';
import '../../features/anciens/data/datasources/anciens_local_datasource.dart';
import '../../features/evenements/data/datasources/evenements_remote_datasource.dart';
import '../../features/evenements/data/datasources/evenements_local_datasource.dart';
import '../../features/evenements/domain/evenement_gestion_statuts.dart';
import '../../features/mes_depenses/data/datasources/mes_depenses_remote_datasource.dart';
import '../../features/mes_depenses/data/datasources/mes_depenses_local_datasource.dart';
import '../../features/about_church/data/datasources/about_church_remote_data_source.dart';
import '../../features/about_church/data/datasources/about_church_local_datasource.dart';
import '../../features/celebrations/data/datasources/celebrations_remote_datasource.dart';
import '../../features/celebrations/data/datasources/celebrations_local_datasource.dart';
import '../config/api_config.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Service de synchronisation Offline-First.
///
/// Il pre-charge les donnees utiles dans Isar et applique les deltas quand
/// l'application retrouve le reseau. Les erreurs sont loguees sans vider l'UI:
/// les ecrans continuent d'afficher le dernier cache local disponible.
class SyncService {
  SyncService({
    required this.dio,
    required this.publicationsRemote,
    required this.publicationsLocal,
    required this.badgeRemote,
    required this.badgeLocal,
    required this.signatureRemote,
    required this.signatureLocal,
    required this.historiquePersoLocal,
    required this.financesRemote,
    required this.financesLocal,
    required this.rapportSecretaireRemote,
    required this.rapportSecretaireLocal,
    required this.anciensLocal,
    required this.evenementsRemote,
    required this.evenementsLocal,
    required this.mesDepensesRemote,
    required this.mesDepensesLocal,
    required this.aboutChurchRemote,
    required this.aboutChurchLocal,
    required this.celebrationsRemote,
    required this.celebrationsLocal,
  });

  final Dio dio;
  final PublicationsRemoteDataSource publicationsRemote;
  final PublicationsLocalDataSource publicationsLocal;
  final BadgeRemoteDataSource badgeRemote;
  final BadgeLocalDataSource badgeLocal;
  final SignatureRemoteDataSource signatureRemote;
  final SignatureLocalDataSource signatureLocal;
  final HistoriquePersoLocalDataSource historiquePersoLocal;
  final FinancesRemoteDataSource financesRemote;
  final FinancesLocalDataSource financesLocal;
  final RapportSecretaireRemoteDataSource rapportSecretaireRemote;
  final RapportSecretaireLocalDataSource rapportSecretaireLocal;
  final AnciensLocalDataSource anciensLocal;
  final EvenementsRemoteDataSource evenementsRemote;
  final EvenementsLocalDataSource evenementsLocal;
  final MesDepensesRemoteDataSource mesDepensesRemote;
  final MesDepensesLocalDataSource mesDepensesLocal;
  final AboutChurchRemoteDataSource aboutChurchRemote;
  final AboutChurchLocalDataSource aboutChurchLocal;
  final CelebrationsRemoteDataSource celebrationsRemote;
  final CelebrationsLocalDataSource celebrationsLocal;

  bool _syncInProgress = false;
  DateTime? _lastSyncCompletedAt;

  /// Évite un double sync quasi-simultané (ex: splash qui attend la sync
  /// puis le bootstrap du shell qui se déclenche juste après sur le même
  /// changement d'état auth).
  static const _minIntervalBetweenSyncs = Duration(seconds: 5);

  Future<void> initialSync() async {
    if (_syncInProgress) return;
    final last = _lastSyncCompletedAt;
    if (last != null && DateTime.now().difference(last) < _minIntervalBetweenSyncs) {
      return;
    }
    _syncInProgress = true;

    AppLogger.debug('[Sync] Debut synchronisation offline-first.');

    try {
      final results = await Future.wait([
        _syncPublications(),
        _syncBadges(),
        _syncMaCarte(),
        _syncHistoriqueSignatures(),
        _syncHistoriquePersonnel(),
        _syncFinances(),
        _syncRapportSecretaire(),
        _syncAnciens(),
        _syncEvenements(),
        _syncEvenementsGestion(),
        _syncMesDepenses(),
        _syncAboutChurch(),
        _syncCelebrations(),
      ], eagerError: false);

      AppLogger.debug('[Sync] Termine (${results.length} taches executees).');
      _lastSyncCompletedAt = DateTime.now();
    } finally {
      _syncInProgress = false;
    }
  }

  Future<void> _syncPublications() async {
    try {
      final latest = await publicationsLocal.latestUpdatedAt;
      if (latest != null) {
        final delta = await publicationsRemote.deltaSince(
          latest,
          const {'per_page': 50},
        );
        await publicationsLocal.applyRemoteChanges(
          delta.items.map((m) => m.toEntity()).toList(),
          delta.deletedIds,
        );
        AppLogger.debug(
          '[Sync] Publications delta: ${delta.items.length} maj, ${delta.deletedIds.length} suppression(s).',
        );
        return;
      }

      final items = await publicationsRemote.list(const {'per_page': 50});
      await publicationsLocal.saveAll(items.map((m) => m.toEntity()).toList());
      AppLogger.debug('[Sync] Publications: ${items.length} entree(s) mises en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] Publications: echec - $e');
    }
  }

  Future<void> _syncBadges() async {
    try {
      final model = await badgeRemote.fetchBadgeCounts();
      await badgeLocal.save(model.toEntity());
      AppLogger.debug('[Sync] Badges mis en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] Badges: echec - $e');
    }
  }

  Future<void> _syncMaCarte() async {
    try {
      final year = DateTime.now().year;
      final raw = await signatureRemote.getMaCarteRaw(year);
      await signatureLocal.saveMaCarte(year, raw);
      AppLogger.debug('[Sync] Ma Carte $year mise en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] Ma Carte: echec - $e');
    }
  }

  Future<void> _syncHistoriqueSignatures() async {
    // Toujours "completed" : signatures présentiel, synchrones (cash), sans
    // état pending/failed intermédiaire — contrairement à l'historique
    // personnel (paiement mobile money à distance, voir _syncHistoriquePersonnel).
    final filters = defaultHistoriqueFilters(status: 'completed');
    try {
      final response = await dio.get(
        '/signatures/historique-signatures',
        queryParameters: {
          'per_page': filters['per_page'].toString(),
          'status': filters['status'],
          'year': filters['year'],
        },
      );
      final raw = ((response.data['data'] as List?) ?? [])
          .cast<Map<String, dynamic>>();
      await signatureLocal.saveHistoriqueSignatures(filters, raw);
      AppLogger.debug('[Sync] Historique signatures mis en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] Historique signatures: echec - $e');
    }
  }

  Future<void> _syncHistoriquePersonnel() async {
    // Pas de filtre status : voir doc de defaultHistoriqueFilters — tous les
    // statuts (pending/completed/failed) doivent remonter ici.
    final filters = defaultHistoriqueFilters();
    final queryParams = {
      'per_page': filters['per_page'].toString(),
      'year': filters['year'],
    };
    try {
      final results = await Future.wait([
        dio.get('/signatures/historique-personnel', queryParameters: queryParams),
        dio.get('/signatures/historique-personnel-presentiel', queryParameters: queryParams),
      ]);

      final rawForCache = <Map<String, dynamic>>[];
      if (results[0].statusCode == 200) {
        final data = (results[0].data['data'] as List?) ?? [];
        rawForCache.addAll(data.cast<Map<String, dynamic>>());
      }
      if (results[1].statusCode == 200) {
        final data = (results[1].data['data'] as List?) ?? [];
        for (final dynamic s in data) {
          if (s is Map<String, dynamic>) {
            rawForCache.add({...s, 'signatureType': 'presentiel'});
          }
        }
      }

      await historiquePersoLocal.save(filters, rawForCache);
      AppLogger.debug('[Sync] Historique personnel mis en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] Historique personnel: echec - $e');
    }
  }

  Future<void> _syncFinances() async {
    try {
      final year = DateTime.now().year;
      final raw = await financesRemote.getRapportAnnuelRaw(year);
      await financesLocal.saveAnnual(year, raw);
      AppLogger.debug('[Sync] Finances $year mises en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] Finances: echec - $e');
    }
  }

  Future<void> _syncRapportSecretaire() async {
    try {
      final now = DateTime.now();
      final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final raw = await rapportSecretaireRemote.getRapportSecretaireRaw(month: month);
      await rapportSecretaireLocal.save(month, raw);
      AppLogger.debug('[Sync] Rapport secretaire $month mis en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] Rapport secretaire: echec - $e');
    }
  }

  Future<void> _syncAnciens() async {
    try {
      final now = DateTime.now();
      final resp = await dio.get(
        ApiConfig.ancienDesignations,
        queryParameters: {'mois': now.month, 'annee': now.year},
      );
      if (resp.statusCode != 200) return;

      final respData = resp.data is Map ? resp.data : {};
      final data = respData['data'] ?? respData;
      final designesRaw = (data['designes'] as List?) ?? [];
      final nonDesignesRaw = (data['non_designes'] as List?) ?? [];

      final rawAll = [
        ...designesRaw.cast<Map<String, dynamic>>().map(
            (e) => {...e, 'mois': now.month, 'annee': now.year, 'designe': true}),
        ...nonDesignesRaw.cast<Map<String, dynamic>>().map(
            (e) => {...e, 'mois': now.month, 'annee': now.year, 'designe': false}),
      ];
      await anciensLocal.save(now.month, now.year, rawAll);
      AppLogger.debug('[Sync] Anciens ${now.month}/${now.year} mis en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] Anciens: echec - $e');
    }
  }

  /// Aucune suppression n'est jamais exposée côté backend pour les
  /// événements : delta simplifié (upserts uniquement, pas de purge).
  Future<void> _syncEvenements() async {
    try {
      final latest = await evenementsLocal.latestUpdatedAt;
      final items = latest != null
          ? await evenementsRemote.deltaSince(latest, const {'per_page': 50})
          : await evenementsRemote.list(const {'per_page': 50});
      await evenementsLocal.saveAll(items.map((m) => m.toEntity()).toList());
      AppLogger.debug('[Sync] Evenements: ${items.length} entree(s) mises en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] Evenements: echec - $e');
    }
  }

  /// Précharge le cache Isar partagé des événements avec TOUS les statuts
  /// utiles à l'écran "Gérer les événements" (y compris brouillon/planifié,
  /// que [_syncEvenements] — le fil d'actualité public — ne couvre pas
  /// forcément).
  Future<void> _syncEvenementsGestion() async {
    try {
      final statuts = '$kEvenementsGestionActifs,$kEvenementsGestionArchives';
      final models = await evenementsRemote.listGestionAllPages(statut: statuts);
      await evenementsLocal.saveAll(models.map((m) => m.toEntity()).toList());
      AppLogger.debug('[Sync] Evenements gestion: ${models.length} entree(s) mises en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] Evenements gestion: echec - $e');
    }
  }


  Future<void> _syncMesDepenses() async {
    try {
      final now = DateTime.now();
      final rows = await mesDepensesRemote.list(annee: now.year);
      await mesDepensesLocal.saveList(now.year, null, rows);

      final stats = await mesDepensesRemote.stats(annee: now.year);
      await mesDepensesLocal.saveStats(now.year, null, stats);
      AppLogger.debug('[Sync] Mes depenses ${now.year} mises en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] Mes depenses: echec - $e');
    }
  }

  Future<void> _syncAboutChurch() async {
    try {
      final raw = await aboutChurchRemote.fetchRaw();
      await aboutChurchLocal.savePayload(raw);
      AppLogger.debug('[Sync] A propos de mon Eglise mis en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] A propos de mon Eglise: echec - $e');
    }
  }

  Future<void> _syncCelebrations() async {
    try {
      final raw = await celebrationsRemote.fetchListRaw();
      await celebrationsLocal.saveList(raw);
      AppLogger.debug('[Sync] Celebrations: ${raw.length} entree(s) mises en cache.');
    } catch (e) {
      AppLogger.debug('[Sync] Celebrations: echec - $e');
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    dio: ref.watch(dioProvider),
    publicationsRemote: PublicationsRemoteDataSource(ref.watch(dioProvider)),
    publicationsLocal: PublicationsLocalDataSource(),
    badgeRemote: BadgeRemoteDataSource(ref.watch(dioProvider)),
    badgeLocal: BadgeLocalDataSource(),
    signatureRemote: SignatureRemoteDataSource(ref.watch(dioProvider)),
    signatureLocal: SignatureLocalDataSource(),
    historiquePersoLocal: HistoriquePersoLocalDataSource(),
    financesRemote: FinancesRemoteDataSource(ref.watch(dioProvider)),
    financesLocal: FinancesLocalDataSource(),
    rapportSecretaireRemote: RapportSecretaireRemoteDataSource(ref.watch(dioProvider)),
    rapportSecretaireLocal: RapportSecretaireLocalDataSource(),
    anciensLocal: AnciensLocalDataSource(),
    evenementsRemote: EvenementsRemoteDataSource(ref.watch(dioProvider)),
    evenementsLocal: EvenementsLocalDataSource(),
    mesDepensesRemote: MesDepensesRemoteDataSource(ref.watch(dioProvider)),
    mesDepensesLocal: MesDepensesLocalDataSource(),
    aboutChurchRemote: AboutChurchRemoteDataSource(ref.watch(dioProvider)),
    aboutChurchLocal: AboutChurchLocalDataSource(),
    celebrationsRemote: CelebrationsRemoteDataSource(ref.watch(dioProvider)),
    celebrationsLocal: CelebrationsLocalDataSource(),
  );
});

/// Bootstrap global: lance une sync apres authentification et au retour reseau.
final syncBootstrapProvider = Provider<void>((ref) {
  ref.keepAlive();

  Future<void> syncIfReady() async {
    final auth = ref.read(authNotifierProvider);
    if (!auth.isInitialized || !auth.isAuthenticated) return;

    final isOnline = await ref.read(connectivityServiceProvider).isOnline;
    if (!isOnline) return;

    await ref.read(syncServiceProvider).initialSync();
  }

  ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    final becameAuthenticated = next.isInitialized &&
        next.isAuthenticated &&
        previous?.auth?.accessToken != next.auth?.accessToken;

    if (becameAuthenticated) {
      Future<void>.microtask(syncIfReady);
    }
  });

  ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
    final wasOffline = previous?.valueOrNull == false;
    final isOnline = next.valueOrNull == true;
    if (wasOffline && isOnline) {
      Future<void>.microtask(syncIfReady);
    }
  });

  Future<void>.microtask(syncIfReady);
});
