import 'package:equatable/equatable.dart';
import 'finance_json_helpers.dart';

class RapportMensuelEntity extends Equatable {
  const RapportMensuelEntity({
    required this.month,
    required this.nbTotal,
    required this.nbPresentiel,
    required this.nbDistance,
    required this.montantTotal,
    required this.fraisTotal,
    required this.encaisseTotal,
    required this.signatures,
    required this.distribution,
  });

  final String month;
  final int nbTotal;
  final int nbPresentiel;
  final int nbDistance;
  final double montantTotal;
  final double fraisTotal;
  final double encaisseTotal;
  final List<SignatureMensuelleEntity> signatures;
  final List<DistributionMontantEntity> distribution;

  factory RapportMensuelEntity.empty(String month) => RapportMensuelEntity(
        month: month,
        nbTotal: 0,
        nbPresentiel: 0,
        nbDistance: 0,
        montantTotal: 0,
        fraisTotal: 0,
        encaisseTotal: 0,
        signatures: const [],
        distribution: const [],
      );

  factory RapportMensuelEntity.fromJson(Map<String, dynamic> json) {
    final sigs = (json['signatures'] as List? ?? [])
        .whereType<Map>()
        .map((e) => SignatureMensuelleEntity.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();

    final dist = (json['distribution_montants'] as List? ?? [])
        .whereType<Map>()
        .map((e) => DistributionMontantEntity.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();

    return RapportMensuelEntity(
      month: json['month']?.toString() ?? '',
      nbTotal: parseInt(json['nb_total']),
      nbPresentiel: parseInt(json['nb_presentiel']),
      nbDistance: parseInt(json['nb_distance']),
      montantTotal: parseDouble(json['montant_total']),
      fraisTotal: parseDouble(json['frais_total']),
      encaisseTotal: parseDouble(json['encaisse_total']),
      signatures: sigs,
      distribution: dist,
    );
  }

  @override
  List<Object?> get props => [month, nbTotal, montantTotal, signatures.length];
}

class SignatureMensuelleEntity extends Equatable {
  const SignatureMensuelleEntity({
    required this.id,
    required this.nomParoissien,
    required this.amount,
    required this.fees,
    required this.signatureType,
    this.photoUrl,
    this.paymentMethod,
    this.signedAt,
  });

  final int id;
  final String nomParoissien;
  final double amount;
  final double fees;
  final String signatureType;
  final String? photoUrl;
  final String? paymentMethod;
  final String? signedAt;

  factory SignatureMensuelleEntity.fromJson(Map<String, dynamic> json) {
    return SignatureMensuelleEntity(
      id: parseInt(json['id']),
      nomParoissien: json['nomParoissien']?.toString() ?? '',
      amount: parseDouble(json['amount']),
      fees: parseDouble(json['fees']),
      signatureType: json['signatureType']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      signedAt: json['signed_at']?.toString(),
    );
  }

  bool get isPresentiel => signatureType == 'presentiel';

  @override
  List<Object?> get props => [id, nomParoissien, amount];
}

class DistributionMontantEntity extends Equatable {
  const DistributionMontantEntity({
    required this.amount,
    required this.count,
    required this.total,
  });

  final double amount;
  final int count;
  final double total;

  factory DistributionMontantEntity.fromJson(Map<String, dynamic> json) {
    return DistributionMontantEntity(
      amount: parseDouble(json['amount']),
      count: parseInt(json['count']),
      total: parseDouble(json['total']),
    );
  }

  @override
  List<Object?> get props => [amount, count, total];
}
