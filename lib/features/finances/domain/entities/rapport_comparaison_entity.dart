import 'package:equatable/equatable.dart';
import 'finance_json_helpers.dart';

class RapportComparaisonEntity extends Equatable {
  const RapportComparaisonEntity({
    required this.current,
    required this.previous,
    required this.evolutionPercent,
    required this.evolutionSens,
    required this.difference,
  });

  final AnneeFinanciereEntity current;
  final AnneeFinanciereEntity previous;
  final double evolutionPercent;
  final String evolutionSens;
  final double difference;

  factory RapportComparaisonEntity.empty() => RapportComparaisonEntity(
        current: AnneeFinanciereEntity.empty(DateTime.now().year),
        previous: AnneeFinanciereEntity.empty(DateTime.now().year - 1),
        evolutionPercent: 0,
        evolutionSens: 'stable',
        difference: 0,
      );

  factory RapportComparaisonEntity.fromJson(Map<String, dynamic> json) {
    final evo = json['evolution'] as Map<String, dynamic>? ?? {};
    return RapportComparaisonEntity(
      current: AnneeFinanciereEntity.fromJson(
        json['current'] as Map<String, dynamic>? ?? {},
      ),
      previous: AnneeFinanciereEntity.fromJson(
        json['previous'] as Map<String, dynamic>? ?? {},
      ),
      evolutionPercent: parseDouble(evo['pourcentage']),
      evolutionSens: evo['sens']?.toString() ?? 'stable',
      difference: parseDouble(evo['difference']),
    );
  }

  @override
  List<Object?> get props => [current, previous, evolutionPercent];
}

class AnneeFinanciereEntity extends Equatable {
  const AnneeFinanciereEntity({
    required this.year,
    required this.nbSignatures,
    required this.totalOffrandes,
    required this.totalFrais,
    required this.totalEncaisse,
  });

  final int year;
  final int nbSignatures;
  final double totalOffrandes;
  final double totalFrais;
  final double totalEncaisse;

  factory AnneeFinanciereEntity.empty(int year) => AnneeFinanciereEntity(
        year: year,
        nbSignatures: 0,
        totalOffrandes: 0,
        totalFrais: 0,
        totalEncaisse: 0,
      );

  factory AnneeFinanciereEntity.fromJson(Map<String, dynamic> json) {
    final offrandes = parseDouble(json['total']);
    final frais = parseDouble(json['frais']);
    return AnneeFinanciereEntity(
      year: parseInt(json['year'], DateTime.now().year),
      nbSignatures: parseInt(json['nb']),
      totalOffrandes: offrandes,
      totalFrais: frais,
      totalEncaisse: parseDouble(json['encaisse'], offrandes + frais),
    );
  }

  @override
  List<Object?> get props => [year, nbSignatures, totalOffrandes];
}
