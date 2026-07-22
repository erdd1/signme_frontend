import 'package:equatable/equatable.dart';

class RapportMembreEntity extends Equatable {
  final int id;
  final String nom;
  final String email;
  final String role;
  final String? photoUrl;
  final bool signed;
  final RapportSignatureData? signature; // Null si non signé

  const RapportMembreEntity({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    this.photoUrl,
    required this.signed,
    this.signature,
  });

  factory RapportMembreEntity.fromJson(Map<String, dynamic> json) {
    return RapportMembreEntity(
      id: json['id'] as int,
      nom: json['nom'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      photoUrl: json['photoUrl'] as String?,
      signed: json['signed'] as bool,
      signature: json['signature'] != null
          ? RapportSignatureData.fromJson(json['signature'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, nom, email, role, photoUrl, signed, signature];
}

class RapportSignatureData extends Equatable {
  final double amount;
  final double fees;
  final String signatureType;
  final String paymentMethod;

  const RapportSignatureData({
    required this.amount,
    required this.fees,
    required this.signatureType,
    required this.paymentMethod,
  });

  factory RapportSignatureData.fromJson(Map<String, dynamic> json) {
    return RapportSignatureData(
      amount: _parseDouble(json['amount']),
      fees: _parseDouble(json['fees']),
      signatureType: json['signatureType'] as String,
      paymentMethod: json['paymentMethod'] as String,
    );
  }

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
  List<Object?> get props => [amount, fees, signatureType, paymentMethod];
}
