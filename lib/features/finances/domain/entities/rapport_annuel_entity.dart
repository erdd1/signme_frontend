import 'package:equatable/equatable.dart';
import 'finance_json_helpers.dart';

class RapportAnnuelEntity extends Equatable {
  const RapportAnnuelEntity({
    required this.year,
    required this.monthlyData,
    required this.totalAmount,
    required this.totalFees,
    required this.totalEncaisse,
    required this.totalSignatures,
    this.churchId,
  });

  final int year;
  final List<DonneeMensuelleEntity> monthlyData;
  final double totalAmount;
  final double totalFees;
  final double totalEncaisse;
  final int totalSignatures;
  final int? churchId;

  factory RapportAnnuelEntity.empty([int? year]) => RapportAnnuelEntity(
        year: year ?? DateTime.now().year,
        monthlyData: List.generate(
          12,
          (i) => DonneeMensuelleEntity.empty(i),
        ),
        totalAmount: 0,
        totalFees: 0,
        totalEncaisse: 0,
        totalSignatures: 0,
      );

  factory RapportAnnuelEntity.fromJson(Map<String, dynamic> json) {
    final year = parseInt(json['year'], DateTime.now().year);
    final moisList = json['mois'] as List? ?? [];

    final monthly = List.generate(12, DonneeMensuelleEntity.empty);

    for (final dynamic item in moisList) {
      if (item is! Map<String, dynamic>) continue;
      final idx = parseInt(item['monthIndex']);
      if (idx < 0 || idx >= 12) continue;
      monthly[idx] = DonneeMensuelleEntity.fromJson(item, year);
    }

    final totaux = json['totaux_annuels'] as Map<String, dynamic>?;
    final totalAmount = parseDouble(totaux?['total_offrandes']);
    final totalFees = parseDouble(totaux?['total_frais']);
    final totalEncaisse = parseDouble(
      totaux?['total_encaisse'],
      totalAmount + totalFees,
    );
    final totalSignatures = parseInt(totaux?['nb_signatures']);

    return RapportAnnuelEntity(
      year: year,
      churchId: parseInt(json['eglise_id'], 0) == 0 ? null : parseInt(json['eglise_id']),
      monthlyData: monthly,
      totalAmount: totalAmount > 0
          ? totalAmount
          : monthly.fold<double>(0, (s, m) => s + m.amount),
      totalFees: totalFees > 0
          ? totalFees
          : monthly.fold<double>(0, (s, m) => s + m.totalFees),
      totalEncaisse: totalEncaisse > 0
          ? totalEncaisse
          : monthly.fold<double>(0, (s, m) => s + m.totalEncaisse),
      totalSignatures: totalSignatures > 0
          ? totalSignatures
          : monthly.fold<int>(0, (s, m) => s + m.count),
    );
  }

  bool get isEmpty => totalSignatures == 0 && totalAmount == 0;

  @override
  List<Object?> get props =>
      [year, monthlyData, totalAmount, totalFees, totalEncaisse, totalSignatures];
}

class DonneeMensuelleEntity extends Equatable {
  const DonneeMensuelleEntity({
    required this.monthIndex,
    required this.monthKey,
    required this.monthName,
    required this.count,
    required this.amount,
    required this.totalFees,
    required this.totalEncaisse,
    required this.amountPresentiel,
    required this.amountDistance,
    required this.countPresentiel,
    required this.countDistance,
  });

  final int monthIndex;
  final String monthKey;
  final String monthName;
  final int count;
  final double amount;
  final double totalFees;
  final double totalEncaisse;
  final double amountPresentiel;
  final double amountDistance;
  final int countPresentiel;
  final int countDistance;

  factory DonneeMensuelleEntity.empty(int index) {
    final y = DateTime.now().year;
    final m = (index + 1).toString().padLeft(2, '0');
    return DonneeMensuelleEntity(
      monthIndex: index,
      monthKey: '$y-$m',
      monthName: '',
      count: 0,
      amount: 0,
      totalFees: 0,
      totalEncaisse: 0,
      amountPresentiel: 0,
      amountDistance: 0,
      countPresentiel: 0,
      countDistance: 0,
    );
  }

  factory DonneeMensuelleEntity.fromJson(Map<String, dynamic> json, int year) {
    final idx = parseInt(json['monthIndex']);
    final monthKey = json['month']?.toString() ??
        '$year-${(idx + 1).toString().padLeft(2, '0')}';
    return DonneeMensuelleEntity(
      monthIndex: idx,
      monthKey: monthKey,
      monthName: json['monthName']?.toString() ?? '',
      count: parseInt(json['nb_signatures']),
      amount: parseDouble(json['total_offrandes']),
      totalFees: parseDouble(json['total_frais']),
      totalEncaisse: parseDouble(json['total_encaisse']),
      amountPresentiel: parseDouble(json['montant_presentiel']),
      amountDistance: parseDouble(json['montant_distance']),
      countPresentiel: parseInt(json['nb_presentiel']),
      countDistance: parseInt(json['nb_distance']),
    );
  }

  bool get hasData => count > 0 || amount > 0;

  @override
  List<Object?> get props => [monthIndex, monthKey, count, amount];
}
