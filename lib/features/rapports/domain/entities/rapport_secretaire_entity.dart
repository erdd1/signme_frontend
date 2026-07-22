import 'package:equatable/equatable.dart';

class RapportSecretaireEntity extends Equatable {
  final int totalMembers;
  final int membersSigned;
  final int membersNotSigned;
  final double signatureRate;
  final double totalAmount;
  final String? month;
  final List<Map<String, dynamic>>? signes; // Liste brute des membres signés
  final List<Map<String, dynamic>>? nonSignes; // Liste brute des membres non-signés

  const RapportSecretaireEntity({
    required this.totalMembers,
    required this.membersSigned,
    required this.membersNotSigned,
    required this.signatureRate,
    required this.totalAmount,
    this.month,
    this.signes,
    this.nonSignes,
  });

  factory RapportSecretaireEntity.empty() => const RapportSecretaireEntity(
        totalMembers: 0,
        membersSigned: 0,
        membersNotSigned: 0,
        signatureRate: 0.0,
        totalAmount: 0.0,
      );

  factory RapportSecretaireEntity.fromJson(Map<String, dynamic> json) {
    return RapportSecretaireEntity(
      totalMembers: (json['total_membres'] as num?)?.toInt() ?? 0,
      membersSigned: (json['total_signes'] as num?)?.toInt() ?? 0,
      membersNotSigned: (json['total_non_signes'] as num?)?.toInt() ?? 0,
      signatureRate: _parseDouble(json['taux_signature']),
      totalAmount: _parseDouble(json['montant_collecte']),
      month: json['month']?.toString(),
      signes: json['signes'] != null ? List<Map<String, dynamic>>.from(json['signes'] as List) : null,
      nonSignes: json['non_signes'] != null ? List<Map<String, dynamic>>.from(json['non_signes'] as List) : null,
    );
  }

  /// Helper pour parser un double depuis string ou num
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  @override
  List<Object?> get props => [
        totalMembers,
        membersSigned,
        membersNotSigned,
        signatureRate,
        totalAmount,
        month,
        signes,
        nonSignes,
      ];
}
