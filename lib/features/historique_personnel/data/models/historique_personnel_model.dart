import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/historique_personnel_entity.dart';

part 'historique_personnel_model.g.dart';

@JsonSerializable()
class HistoriquePersonnelModel {
  final String id;
  final String userId;
  final String nomUtilisateur;
  final String month;
  final int year;
  final String status;
  final int amount;
  final int? fees;
  final String signatureType;
  final String? paymentMethod;
  final String? paymentPhoneNumber;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;

  HistoriquePersonnelModel({
    required this.id,
    required this.userId,
    required this.nomUtilisateur,
    required this.month,
    required this.year,
    required this.status,
    required this.amount,
    this.fees,
    required this.signatureType,
    this.paymentMethod,
    this.paymentPhoneNumber,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  factory HistoriquePersonnelModel.fromJson(Map<String, dynamic> json) {
    final year = json['year'] is int 
        ? json['year'] as int 
        : int.tryParse(json['year'].toString()) ?? 0;
    final amount = json['amount'] is int 
        ? json['amount'] as int 
        : int.tryParse(json['amount'].toString()) ?? 0;
    final fees = json['fees'] != null 
        ? (json['fees'] is int ? json['fees'] as int : int.tryParse(json['fees'].toString()))
        : null;
    
    String nomUtilisateur = '';
    if (json.containsKey('nomParoissien') && json['nomParoissien'] != null) {
      nomUtilisateur = json['nomParoissien'].toString();
    } else if (json.containsKey('nomUtilisateur') && json['nomUtilisateur'] != null) {
      nomUtilisateur = json['nomUtilisateur'].toString();
    }

    return HistoriquePersonnelModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      nomUtilisateur: nomUtilisateur,
      month: (json['month'] ?? '').toString(),
      year: year,
      status: (json['status'] ?? '').toString(),
      amount: amount,
      fees: fees,
      signatureType: (json['signatureType'] ?? '').toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      paymentPhoneNumber: json['paymentPhoneNumber']?.toString(),
      // tryParse (jamais parse) : un champ manquant/malformé ne doit jamais
      // faire planter le parsing de toute la liste.
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      completedAt: DateTime.tryParse(json['completed_at']?.toString() ?? ''),
      errorMessage: json['errorMessage']?.toString(),
    );
  }

  /// Méthode Senior pour convertir le modèle de données en entité métier
  HistoriquePersonnelEntity toEntity() {
    return HistoriquePersonnelEntity(
      id: id,
      userId: userId,
      nomUtilisateur: nomUtilisateur,
      month: month,
      year: year,
      status: status,
      amount: amount,
      fees: fees,
      signatureType: signatureType,
      paymentMethod: paymentMethod,
      paymentPhoneNumber: paymentPhoneNumber,
      createdAt: createdAt,
      completedAt: completedAt,
      errorMessage: errorMessage,
    );
  }

  Map<String, dynamic> toJson() => _$HistoriquePersonnelModelToJson(this);
}
