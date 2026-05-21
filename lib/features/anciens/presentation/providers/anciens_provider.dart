import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/ancien_model.dart';
import '../../domain/entities/ancien_entity.dart';

// ── Data Source ────────────────────────────────────────────────────────────
class AncienDataSource {
  AncienDataSource(this.dio);
  final Dio dio;

  /// Récupère les anciens + leurs désignations pour un mois/année
  /// Le backend filtre automatiquement par l'église de l'utilisateur authentifié
  Future<List<AncienEntity>> getAnciens({
    required int mois,
    required int annee,
  }) async {
    try {
      print('🔍 [AncienDataSource] Requête GET $ApiConfig.ancienDesignations?mois=$mois&annee=$annee');
      
      final resp = await dio.get(
        ApiConfig.ancienDesignations,
        queryParameters: {
          'mois': mois,
          'annee': annee,
        },
      );
      
      print('📡 [AncienDataSource] Status: ${resp.statusCode}');
      print('📦 [AncienDataSource] Response data: ${resp.data}');
      
      if (resp.statusCode == 200) {
        // Backend retourne: {success?, data: {designes: [...], non_designes: [...], mois, annee, eglise_id, total_designes}}
        // OU directement: {designes: [...], non_designes: [...], ...}
        final respData = resp.data is Map ? resp.data : {};
        final data = respData['data'] ?? respData;
        
        final List<dynamic> designes = data['designes'] as List? ?? [];
        final List<dynamic> nonDesignes = data['non_designes'] as List? ?? [];
        
        print('✅ [AncienDataSource] Designés: ${designes.length}, Non-désignés: ${nonDesignes.length}');
        
        // Merger les deux listes et enrichir avec mois/annee
        final List<Map<String, dynamic>> allAnciens = [
          ...designes.map((e) {
            final map = Map<String, dynamic>.from(e as Map);
            map['mois'] = mois;
            map['annee'] = annee;
            return map;
          }),
          ...nonDesignes.map((e) {
            final map = Map<String, dynamic>.from(e as Map);
            map['mois'] = mois;
            map['annee'] = annee;
            return map;
          }),
        ];
        
        return allAnciens
            .map((e) => AncienModel.fromJson(e))
            .toList();
      }
      print('⚠️ [AncienDataSource] Status non-200: ${resp.statusCode}');
      return [];
    } catch (e) {
      print('❌ [AncienDataSource] Erreur: $e');
      rethrow;
    }
  }

  /// Désigne un ancien avec paramètres (jours, horaires)
  Future<bool> designateAncien({
    required int ancienId,
    required int mois,
    required int annee,
    List<int>? joursTravail,
    String? horairesDebut,
    String? horairesFin,
  }) async {
    try {
      print('📝 [AncienDataSource] Désignation: ancien=$ancienId, mois=$mois, annee=$annee');
      print('   jours=$joursTravail, debut=$horairesDebut, fin=$horairesFin');
      
      final data = {
        'ancien_id': ancienId,
        'mois': mois,
        'annee': annee,
        if (joursTravail != null) 'jours_travail': joursTravail,
        if (horairesDebut != null) 'horaire_debut': horairesDebut,
        if (horairesFin != null) 'horaire_fin': horairesFin,
      };
      print('   📤 POST ${ApiConfig.ancienDesignations} avec: $data');
      
      final resp = await dio.post(
        ApiConfig.ancienDesignations,
        data: data,
      );
      
      print('   ✅ Réponse ${resp.statusCode}: ${resp.data}');
      return resp.statusCode == 201 || resp.statusCode == 200;
    } catch (e) {
      print('   ❌ Erreur lors de la désignation: $e');
      throw Exception('Impossible de désigner ancien: $e');
    }
  }

  /// Révoque la désignation d'un ancien
  Future<bool> revokeAncien(int designationId) async {
    try {
      print('🗑️  [AncienDataSource] Révocation: designationId=$designationId');
      final url = '${ApiConfig.ancienDesignations}/$designationId';
      print('   📤 DELETE $url');
      
      final resp = await dio.delete(url);
      
      print('   ✅ Réponse ${resp.statusCode}: ${resp.data}');
      return resp.statusCode == 200 || resp.statusCode == 204;
    } catch (e) {
      print('   ❌ Erreur lors de la révocation: $e');
      throw Exception('Impossible de révoquer ancien: $e');
    }
  }
}

final ancienDataSourceProvider = Provider<AncienDataSource>((ref) {
  return AncienDataSource(ref.watch(dioProvider));
});

// ── State ──────────────────────────────────────────────────────────────────
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
    bool clearError = false,
    bool clearSuccess = false,
  }) =>
      AncienState(
        anciens: anciens ?? this.anciens,
        mois: mois ?? this.mois,
        annee: annee ?? this.annee,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        success: clearSuccess ? false : success ?? this.success,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────
class AncienNotifier extends StateNotifier<AncienState> {
  AncienNotifier(this._ds) : super(const AncienState()) {
    // Initialiser avec le mois/année actuel
    final now = DateTime.now();
    _loadAnciens(now.month, now.year);
  }

  final AncienDataSource _ds;

  /// Charge les anciens pour un mois/année spécifique
  /// Le backend détermine l'église de l'utilisateur via le token d'authentification
  Future<void> _loadAnciens(int mois, int annee) async {
    print('📅 [AncienNotifier] Chargement des anciens: mois=$mois, annee=$annee');
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      mois: mois,
      annee: annee,
    );
    try {
      final items = await _ds.getAnciens(mois: mois, annee: annee);
      print('✅ [AncienNotifier] ${items.length} anciens chargés');
      state = state.copyWith(anciens: items, isLoading: false);
    } catch (e) {
      print('❌ [AncienNotifier] Erreur: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Change le mois/année et recharge
  Future<void> changeMonth(int mois, int annee) => _loadAnciens(mois, annee);

  /// Mois suivant
  Future<void> nextMonth() {
    final now = DateTime(state.annee, state.mois + 1);
    return _loadAnciens(now.month, now.year);
  }

  /// Mois précédent
  Future<void> previousMonth() {
    final now = DateTime(state.annee, state.mois - 1);
    return _loadAnciens(now.month, now.year);
  }

  /// Désigne un ancien avec paramètres
  Future<bool> designate({
    required int ancienId,
    List<int>? joursTravail,
    String? horairesDebut,
    String? horairesFin,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
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
        state = state.copyWith(success: true);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Erreur de désignation');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Révoque la désignation d'un ancien
  Future<bool> revoke(int designationId) async {
    print('🗑️  [AncienNotifier] Début de révocation: designationId=$designationId');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ok = await _ds.revokeAncien(designationId);
      print('🗑️  [AncienNotifier] Revoke réussi: $ok');
      
      if (ok) {
        print('🗑️  [AncienNotifier] Rechargement des anciens...');
        await _loadAnciens(state.mois, state.annee);
        print('🗑️  [AncienNotifier] Succès de révocation complet');
        state = state.copyWith(success: true);
        return true;
      }
      print('🗑️  [AncienNotifier] Revoke retourné false');
      state = state.copyWith(isLoading: false, error: 'Erreur de révocation');
      return false;
    } catch (e) {
      print('🗑️  [AncienNotifier] Exception: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Rafraîchir les données
  Future<void> refresh() => _loadAnciens(state.mois, state.annee);
}

final ancienProvider =
    StateNotifierProvider<AncienNotifier, AncienState>((ref) {
  return AncienNotifier(ref.watch(ancienDataSourceProvider));
});

