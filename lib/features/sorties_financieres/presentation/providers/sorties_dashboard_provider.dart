import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sorties_financieres_provider.dart';
import '../../domain/entities/sorties_dashboard_stats_entity.dart';

class SortiesFilter {
  const SortiesFilter({
    this.year,
    this.month,
  });

  final int? year;
  final int? month;

  bool get hasAnyFilter => year != null || month != null;

  Map<String, dynamic> toQueryParams() => {
        if (year != null) 'year': year,
        if (month != null) 'month': month,
      };

  SortiesFilter copyWith({
    Object? year = _sentinel,
    Object? month = _sentinel,
  }) =>
      SortiesFilter(
        year: year == _sentinel ? this.year : year as int?,
        month: month == _sentinel ? this.month : month as int?,
      );

  static const SortiesFilter empty = SortiesFilter();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortiesFilter &&
          other.year == year &&
          other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}

const _sentinel = Object();

final sortiesDashboardProvider = FutureProvider.family<SortiesDashboardStatsEntity, SortiesFilter>(
  (ref, filter) async {
    final remote = ref.watch(sortiesRemoteDataSourceProvider);
    return remote.fetchDashboard(params: filter.toQueryParams());
  },
);
