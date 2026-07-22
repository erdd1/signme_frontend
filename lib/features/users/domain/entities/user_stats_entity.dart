import 'package:equatable/equatable.dart';

/// Statistiques démographiques pour le tableau de bord "Gérer utilisateurs".
class UserStatsEntity extends Equatable {
  const UserStatsEntity({
    required this.totalFideles,
    required this.hommes,
    required this.femmes,
    required this.auCameroun,
    required this.horsCameroun,
  });

  final int totalFideles;
  final int hommes;
  final int femmes;
  final int auCameroun;
  final int horsCameroun;

  factory UserStatsEntity.fromJson(Map<String, dynamic> json) {
    return UserStatsEntity(
      totalFideles: (json['total_fideles'] as num?)?.toInt() ?? 0,
      hommes: (json['hommes'] as num?)?.toInt() ?? 0,
      femmes: (json['femmes'] as num?)?.toInt() ?? 0,
      auCameroun: (json['au_cameroun'] as num?)?.toInt() ?? 0,
      horsCameroun: (json['hors_cameroun'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    totalFideles,
    hommes,
    femmes,
    auCameroun,
    horsCameroun,
  ];
}
