import 'package:equatable/equatable.dart';
import 'finance_json_helpers.dart';

/// Détail agrégé d'un mois (totaux uniquement — la liste nominative des
/// signataires existe déjà dans "Rapport secrétaire", pas dupliquée ici).
class RapportMensuelEntity extends Equatable {
  const RapportMensuelEntity({
    required this.month,
    required this.nbTotal,
    required this.nbPresentiel,
    required this.nbDistance,
    required this.montantTotal,
    required this.fraisTotal,
    required this.encaisseTotal,
  });

  final String month;
  final int nbTotal;
  final int nbPresentiel;
  final int nbDistance;
  final double montantTotal;
  final double fraisTotal;
  final double encaisseTotal;

  factory RapportMensuelEntity.empty(String month) => RapportMensuelEntity(
        month: month,
        nbTotal: 0,
        nbPresentiel: 0,
        nbDistance: 0,
        montantTotal: 0,
        fraisTotal: 0,
        encaisseTotal: 0,
      );

  factory RapportMensuelEntity.fromJson(Map<String, dynamic> json) {
    return RapportMensuelEntity(
      month: json['month']?.toString() ?? '',
      nbTotal: parseInt(json['nb_total']),
      nbPresentiel: parseInt(json['nb_presentiel']),
      nbDistance: parseInt(json['nb_distance']),
      montantTotal: parseDouble(json['montant_total']),
      fraisTotal: parseDouble(json['frais_total']),
      encaisseTotal: parseDouble(json['encaisse_total']),
    );
  }

  @override
  List<Object?> get props => [month, nbTotal, montantTotal];
}
