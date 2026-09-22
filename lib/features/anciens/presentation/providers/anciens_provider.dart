import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/ancien_model.dart';
import '../../domain/entities/ancien_entity.dart';
import '../../data/datasources/anciens_local_datasource.dart';

// ── Data Source Typé ───────────────────────────────────────────────────────
class AncienDataSource {
  AncienDataSource(this.dio, this.local, this.connectivity);

  final Dio dio;
  final AnciensLocalDataSource local;
  final ConnectivityService connectivity;

  Future<List<AncienEntity>> getAnciens({
    required int mois,
    required int annee,
  }) async {
    final isOnline = await connectivity.isOnline;

    if (isOnline) {
      try {
        final resp = await dio.get(
          ApiConfig.ancienDesignations,
          queryParameters: {'mois': mois, 'annee': annee},
        );

        if (resp.statusCode == 200) {
          final respData = resp.data is Map ? resp.data : {};
          final data = respData['data'] ?? respData;

          final List<dynamic> designesRaw   = data['designes'] as List? ?? [];
          final List<dynamic> nonDesignesRaw = data['non_designes'] as List? ?? [];

          AncienEntity _mapEntry(dynamic e) {
            final map = Map<String, dynamic>.from(e as Map);
            map['mois']  = mois;
            map['annee'] = annee;
            return AncienModel.fromJson(map);
          }

          final all = [
            ...designesRaw.map(_mapEntry),
            ...nonDesignesRaw.map(_mapEntry),
          ];

          // Persister en cache Isar
          final rawAll = [
            ...designesRaw.cast<Map<String, dynamic>>()
                .map((e) => {...e, 'mois': mois, 'annee': annee, 'designe': true}),
            ...nonDesignesRaw.cast<Map<String, dynamic>>()
                .map((e) => {...e, 'mois': mois, 'annee': annee, 'designe': false}),
          ];
          await local.save(mois, annee, rawAll);

          return all;
        }
        return [];
      } catch (_) {
        // Fallback cache ci-dessous
      }
    }

    // ── Hors ligne : retourner le cache ──────────────────────────────────
    final cached = await local.get(mois, annee);
    if (cached != null) {
      return cached.map((e) => AncienModel.fromJson(e)).toList();
    }
    return [];
  }


  Future<bool> designateAncien({
    required int ancienId,
    required int mois,
    required int annee,
    List<int>? joursTravail,
    String? horairesDebut,
    String? horairesFin,
  }) async {
    final Map<String, dynamic> payload = {
      'ancien_id': ancienId,
      'mois': mois,
      'annee': annee,
      if (joursTravail != null) 'jours_travail': joursTravail,
      if (horairesDebut != null) 'horaire_debut': horairesDebut,
      if (horairesFin != null) 'horaire_fin': horairesFin,
    };
    
    final resp = await dio.post(ApiConfig.ancienDesignations, data: payload);
    return resp.statusCode == 201 || resp.statusCode == 200;
  }

  Future<bool> revokeAncien(int designationId) async {
    final resp = await dio.delete('${ApiConfig.ancienDesignations}/$designationId');
    return resp.statusCode == 200 || resp.statusCode == 204;
  }
}

final ancienDataSourceProvider = Provider<AncienDataSource>((ref) {
  return AncienDataSource(
    ref.watch(dioProvider),
    AnciensLocalDataSource(),
    ref.read(connectivityServiceProvider),
  );
});

// ── State Typé ─────────────────────────────────────────────────────────────
class AncienState {
  const AncienState({
    this.anciens = const [],
    this.mois = 1,
    this.annee = 2026,
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  final List<AncienEntity> anciens;
  final int mois;
  final int annee;
  final bool isLoading;
  final String? error;
  final bool success;

  AncienState copyWith({
    List<AncienEntity>? anciens,
    int? mois,
    int? annee,
    bool? isLoading,
    String? error,
    bool? success,
  }) =>
      AncienState(
        anciens: anciens ?? this.anciens,
        mois: mois ?? this.mois,
        annee: annee ?? this.annee,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        success: success ?? this.success,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────
class AncienNotifier extends StateNotifier<AncienState> {
  static const int minYear = 2026;
  static const int maxYear = 2030;
  AncienNotifier(this._ds) : super(const AncienState()) {
    final now = DateTime.now();

    final year = now.year.clamp(2026, 2030);

    _loadAnciens(now.month, year);
  }

  final AncienDataSource _ds;

  Future<void> _loadAnciens(int mois, int annee, {bool silent = false}) async {
    final isSameMonth = state.mois == mois && state.annee == annee;
    final hasData = isSameMonth && state.anciens.isNotEmpty;

    // Ne montrer le shimmer que si on change réellement de mois/année ou
    // qu'on n'a encore aucune donnée — un rafraîchissement silencieux du
    // mois déjà affiché ne doit jamais faire disparaître la liste.
    if (!silent || !hasData) {
      state = state.copyWith(isLoading: true, mois: mois, annee: annee);
    } else {
      state = state.copyWith(mois: mois, annee: annee);
    }

    try {
      final items = await _ds.getAnciens(mois: mois, annee: annee);
      state = state.copyWith(anciens: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: hasData ? null : messageFromError(e),
      );
    }
  }

  /// Rafraîchit silencieusement le mois courant (appelé à chaque ouverture
  /// de l'écran) sans jamais cacher les données déjà affichées.
  Future<void> refreshSilently() => _loadAnciens(state.mois, state.annee, silent: true);

  Future<void> changeMonth(int mois, int annee) async {
    if (annee < minYear || annee > maxYear) {
      return;
    }

    await _loadAnciens(mois, annee);
  }

  Future<void> nextMonth() async {
    // Limite haute : Décembre 2030
    if (state.annee == maxYear && state.mois == 12) {
      return;
    }

    final mois =
    state.mois == 12 ? 1 : state.mois + 1;

    final annee =
    state.mois == 12 ? state.annee + 1 : state.annee;

    await _loadAnciens(mois, annee);
  }

  Future<void> previousMonth() async {
    // Limite basse : Janvier 2026
    if (state.annee == minYear && state.mois == 1) {
      return;
    }

    final mois =
    state.mois == 1 ? 12 : state.mois - 1;

    final annee =
    state.mois == 1 ? state.annee - 1 : state.annee;

    await _loadAnciens(mois, annee);
  }

  Future<bool> designate({
    required int ancienId,
    List<int>? joursTravail,
    String? horairesDebut,
    String? horairesFin,
  }) async {
    // Le bouton se désactive via `isLoading`, mais seulement au prochain
    // frame — un double-tap très rapide peut encore appeler cette méthode
    // deux fois avant ce rendu.
    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true);
    try {
      final ok = await _ds.designateAncien(
        ancienId: ancienId,
        mois: state.mois,
        annee: state.annee,
        joursTravail: joursTravail,
        horairesDebut: horairesDebut,
        horairesFin: horairesFin,
      );
      if (ok) {
        await _loadAnciens(state.mois, state.annee);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: messageFromError(e));
      return false;
    }
  }

  Future<bool> revoke(int designationId) async {
    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true);
    try {
      final ok = await _ds.revokeAncien(designationId);
      if (ok) {
        await _loadAnciens(state.mois, state.annee);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: messageFromError(e));
      return false;
    }
  }

  Future<void> refresh() => _loadAnciens(state.mois, state.annee);
}

final ancienProvider = StateNotifierProvider<AncienNotifier, AncienState>((ref) {
  ref.keepAlive();
  return AncienNotifier(ref.watch(ancienDataSourceProvider));
});

/// Précharge les anciens du mois courant au login.
final ancienBootstrapProvider = Provider<void>((ref) {
  ref.keepAlive();
  ref.listen<AuthState>(
    authNotifierProvider,
    (previous, next) {
      if (next.isInitialized && next.isAuthenticated &&
          previous?.isAuthenticated != true) {
        Future<void>.microtask(() => ref.read(ancienProvider.notifier).refreshSilently());
      }
    },
    fireImmediately: true,
  );
});
