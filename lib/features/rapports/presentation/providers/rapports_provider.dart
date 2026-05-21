import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ── Data Source ────────────────────────────────────────────────────────────
class RapportDataSource {
  RapportDataSource(this.dio);
  final Dio dio;

  Future<Map<String, dynamic>> getRapportSecretaire({String? month}) async {
    try {
      final params = <String, dynamic>{};
      if (month != null) params['month'] = month;
      
      final resp = await dio.get(
        '${ApiConfig.baseUrl}/rapports/secretaire',
        queryParameters: params,
      );
      if (resp.statusCode == 200) {
        return resp.data['data'] as Map<String, dynamic>? ?? {};
      }
      return {};
    } catch (e) {
      throw Exception('Impossible de charger le rapport: $e');
    }
  }

  Future<Map<String, dynamic>> getRapportMensuel(String month) async {
    try {
      final resp = await dio.get(
        ApiConfig.rapportMensuel,
        queryParameters: {'month': month},
      );
      if (resp.statusCode == 200) {
        return resp.data['data'] as Map<String, dynamic>? ?? {};
      }
      return {};
    } catch (e) {
      throw Exception('Impossible de charger le rapport mensuel: $e');
    }
  }
}

final rapportDataSourceProvider = Provider<RapportDataSource>((ref) {
  return RapportDataSource(ref.watch(dioProvider));
});

// ── State ──────────────────────────────────────────────────────────────────
class RapportState {
  const RapportState({
    this.data = const {},
    this.isLoading = false,
    this.error,
  });

  final Map<String, dynamic> data;
  final bool isLoading;
  final String? error;

  RapportState copyWith({
    Map<String, dynamic>? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      RapportState(
        data: data ?? this.data,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────
class RapportSecretaireNotifier extends StateNotifier<RapportState> {
  RapportSecretaireNotifier(this._ds) : super(const RapportState()) {
    load();
  }

  final RapportDataSource _ds;

  Future<void> load({String? month}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _ds.getRapportSecretaire(month: month);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh({String? month}) => load(month: month);
}

final rapportSecretaireProvider =
    StateNotifierProvider<RapportSecretaireNotifier, RapportState>((ref) {
  return RapportSecretaireNotifier(ref.watch(rapportDataSourceProvider));
});
