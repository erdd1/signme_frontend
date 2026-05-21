import 'package:json_annotation/json_annotation.dart';

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
    // ✅ FIX: Gérer les conversions de type de façon ultra-robuste
    final year = json['year'] is int 
        ? json['year'] as int 
        : int.tryParse(json['year'].toString()) ?? 0;
    final amount = json['amount'] is int 
        ? json['amount'] as int 
        : int.tryParse(json['amount'].toString()) ?? 0;
    final fees = json['fees'] != null 
        ? (json['fees'] is int ? json['fees'] as int : int.tryParse(json['fees'].toString()))
        : null;
    
    // Convertir nomUtilisateur en String de manière sûre
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
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      errorMessage: json['errorMessage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'nomParoissien': nomUtilisateur,
      'month': month,
      'year': year,
      'status': status,
      'amount': amount,
      'fees': fees,
      'signatureType': signatureType,
      'paymentMethod': paymentMethod,
      'paymentPhoneNumber': paymentPhoneNumber,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }
}
