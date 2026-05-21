import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/signature_entity.dart';
import '../../data/models/signature_model.dart';

// ── DataSource ───────────────────────────────────────────────────────────────
class SignatureDataSource {
  SignatureDataSource(this.dio);
  final Dio dio;

  Future<MaCarteData> getMaCarte(int year) async {
    final resp = await dio.get(ApiConfig.signatureMaCarte, queryParameters: {'year': year});
    if (resp.statusCode == 200 && resp.data['success'] == true) {
      return MaCarteData.fromJson(resp.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Impossible de charger Ma Carte');
  }

  Future<List<SignatureEntity>> getHistorique({
    int page = 1,
    String? month,
    String? status,
    String? type,
  }) async {
    final resp = await dio.get(
      ApiConfig.signatureHistorique,
      queryParameters: {
        'page':     page,
        'per_page': 20,
        if (month  != null) 'month':  month,
        if (status != null) 'status': status,
        if (type   != null) 'type':   type,
      },
    );
    if (resp.statusCode == 200) {
      final List<dynamic> items = resp.data['data']?['data'] as List? ?? [];
      return items.map((e) => SignatureModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getRapportAnnuel(int year) async {
    final resp = await dio.get(
      ApiConfig.rapportAnnuel,
      queryParameters: {'year': year},
    );
    if (resp.statusCode == 200 && resp.data['success'] == true) {
      return resp.data['data'] as Map<String, dynamic>;
    }
    return {};
  }
}

final signatureDataSourceProvider = Provider<SignatureDataSource>((ref) {
  return SignatureDataSource(ref.watch(dioProvider));
});

// ── Ma Carte Provider ─────────────────────────────────────────────────────────
class MaCarteState {
  const MaCarteState({
    this.data,
    this.year,
    this.isLoading = false,
    this.error,
  });

  final MaCarteData? data;
  final int?         year;
  final bool         isLoading;
  final String?      error;

  MaCarteState copyWith({MaCarteData? data, int? year, bool? isLoading, String? error, bool clearError = false}) =>
      MaCarteState(
        data:      data      ?? this.data,
        year:      year      ?? this.year,
        isLoading: isLoading ?? this.isLoading,
        error:     clearError ? null : error ?? this.error,
      );
}

class MaCarteNotifier extends StateNotifier<MaCarteState> {
  MaCarteNotifier(this._ds) : super(MaCarteState(year: DateTime.now().year)) {
    load(DateTime.now().year);
  }

  final SignatureDataSource _ds;

  Future<void> load(int year) async {
    state = state.copyWith(isLoading: true, year: year, clearError: true);
    try {
      final data = await _ds.getMaCarte(year);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void previousYear() => load((state.year ?? DateTime.now().year) - 1);
  void nextYear()     => load((state.year ?? DateTime.now().year) + 1);
}

final maCarteProvider = StateNotifierProvider<MaCarteNotifier, MaCarteState>((ref) {
  return MaCarteNotifier(ref.watch(signatureDataSourceProvider));
});

// ── Historique Provider ───────────────────────────────────────────────────────
class HistoriqueState {
  const HistoriqueState({
    this.signatures = const [],
    this.isLoading  = false,
    this.hasMore    = true,
    this.page       = 1,
    this.filterType,
    this.filterStatus,
    this.error,
  });

  final List<SignatureEntity> signatures;
  final bool    isLoading;
  final bool    hasMore;
  final int     page;
  final String? filterType;
  final String? filterStatus;
  final String? error;

  HistoriqueState copyWith({
    List<SignatureEntity>? signatures,
    bool?   isLoading,
    bool?   hasMore,
    int?    page,
    String? filterType,
    String? filterStatus,
    String? error,
    bool    clearError = false,
  }) =>
      HistoriqueState(
        signatures:   signatures   ?? this.signatures,
        isLoading:    isLoading    ?? this.isLoading,
        hasMore:      hasMore      ?? this.hasMore,
        page:         page         ?? this.page,
        filterType:   filterType   ?? this.filterType,
        filterStatus: filterStatus ?? this.filterStatus,
        error:        clearError ? null : error ?? this.error,
      );
}

class HistoriqueNotifier extends StateNotifier<HistoriqueState> {
  HistoriqueNotifier(this._ds) : super(const HistoriqueState()) {
    load();
  }

  final SignatureDataSource _ds;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _ds.getHistorique(
        page:   1,
        type:   state.filterType,
        status: state.filterStatus,
      );
      state = state.copyWith(signatures: items, isLoading: false, page: 1, hasMore: items.length >= 20);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final items = await _ds.getHistorique(page: state.page + 1, type: state.filterType, status: state.filterStatus);
      state = state.copyWith(
        signatures: [...state.signatures, ...items],
        isLoading: false, page: state.page + 1, hasMore: items.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter({String? type, String? status, bool clearType = false, bool clearStatus = false}) {
    state = HistoriqueState(
      filterType:   clearType   ? null : type   ?? state.filterType,
      filterStatus: clearStatus ? null : status ?? state.filterStatus,
      // reset pagination
      signatures: const [], page: 1, hasMore: true,
    );
    load();
  }

  void clearFilters() => setFilter(clearType: true, clearStatus: true);

  Future<void> refresh() => load();
}

final historiqueProvider = StateNotifierProvider<HistoriqueNotifier, HistoriqueState>((ref) {
  return HistoriqueNotifier(ref.watch(signatureDataSourceProvider));
});

// ── Finances Provider ─────────────────────────────────────────────────────────
class FinancesState {
  const FinancesState({
    this.data       = const {},
    this.year,
    this.selectedMonthIndex,
    this.isLoading  = false,
    this.error,
  });

  final Map<String, dynamic> data;
  final int?  year;
  final int?  selectedMonthIndex;
  final bool  isLoading;
  final String? error;

  FinancesState copyWith({
    Map<String, dynamic>? data,
    int?    year,
    int?    selectedMonthIndex,
    bool?   isLoading,
    String? error,
    bool    clearError = false,
  }) =>
      FinancesState(
        data:               data              ?? this.data,
        year:               year              ?? this.year,
        selectedMonthIndex: selectedMonthIndex ?? this.selectedMonthIndex,
        isLoading:          isLoading         ?? this.isLoading,
        error:              clearError ? null  : error ?? this.error,
      );
}

class FinancesNotifier extends StateNotifier<FinancesState> {
  FinancesNotifier(this._ds) : super(FinancesState(year: DateTime.now().year)) {
    load(DateTime.now().year);
  }

  final SignatureDataSource _ds;

  Future<void> load(int year) async {
    state = state.copyWith(isLoading: true, year: year, clearError: true);
    try {
      final data = await _ds.getRapportAnnuel(year);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void previousYear() => load((state.year ?? DateTime.now().year) - 1);
  void nextYear()     => load((state.year ?? DateTime.now().year) + 1);
  void selectMonth(int idx) => state = state.copyWith(selectedMonthIndex: idx);
}

final financesProvider = StateNotifierProvider<FinancesNotifier, FinancesState>((ref) {
  return FinancesNotifier(ref.watch(signatureDataSourceProvider));
});
