import 'package:json_annotation/json_annotation.dart';

part 'historique_signatures_model.g.dart';

@JsonSerializable()
class HistoriqueSignaturesModel {
  final String id;
  final String userId;
  final String nomParoissien;
  final String emailParoissien;
  final String ancienId;
  final String nomAncien;
  final String month;
  final int year;
  final String status;
  final int? amount;
  final int? fees;
  final String signatureType;
  final String? location;
  final String churchId;
  final String churchName;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;

  HistoriqueSignaturesModel({
    required this.id,
    required this.userId,
    required this.nomParoissien,
    required this.emailParoissien,
    required this.ancienId,
    required this.nomAncien,
    required this.month,
    required this.year,
    required this.status,
    this.amount,
    this.fees,
    required this.signatureType,
    this.location,
    required this.churchId,
    required this.churchName,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  factory HistoriqueSignaturesModel.fromJson(Map<String, dynamic> json) {
    // ✅ FIX: Gérer les conversions de type de façon robuste avec tryParse
    final year = json['year'] is int 
        ? json['year'] as int 
        : int.tryParse(json['year'].toString()) ?? 0;
    final amount = json['amount'] != null 
        ? (json['amount'] is int ? json['amount'] as int : int.tryParse(json['amount'].toString()))
        : null;
    final fees = json['fees'] != null 
        ? (json['fees'] is int ? json['fees'] as int : int.tryParse(json['fees'].toString()))
        : null;

    return HistoriqueSignaturesModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      nomParoissien: (json['nomParoissien'] ?? '').toString(),
      emailParoissien: (json['emailParoissien'] ?? '').toString(),
      ancienId: (json['ancienId'] ?? '').toString(),
      nomAncien: (json['nomAncien'] ?? '').toString(),
      month: (json['month'] ?? '').toString(),
      year: year,
      status: (json['status'] ?? '').toString(),
      amount: amount,
      fees: fees,
      signatureType: (json['signatureType'] ?? '').toString(),
      location: json['location']?.toString(),
      churchId: (json['churchId'] ?? '').toString(),
      churchName: (json['churchName'] ?? '').toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'nomParoissien': nomParoissien,
      'emailParoissien': emailParoissien,
      'ancienId': ancienId,
      'nomAncien': nomAncien,
      'month': month,
      'year': year,
      'status': status,
      'amount': amount,
      'fees': fees,
      'signatureType': signatureType,
      'location': location,
      'churchId': churchId,
      'churchName': churchName,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}
