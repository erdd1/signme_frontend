// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historique_signatures_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoriqueSignaturesModel _$HistoriqueSignaturesModelFromJson(
        Map<String, dynamic> json) =>
    HistoriqueSignaturesModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      nomParoissien: json['nomParoissien'] as String,
      emailParoissien: json['emailParoissien'] as String,
      ancienId: json['ancienId'] as String,
      nomAncien: json['nomAncien'] as String,
      month: json['month'] as String,
      year: (json['year'] as num).toInt(),
      status: json['status'] as String,
      amount: (json['amount'] as num?)?.toInt(),
      fees: (json['fees'] as num?)?.toInt(),
      signatureType: json['signatureType'] as String,
      location: json['location'] as String?,
      churchId: json['churchId'] as String,
      churchName: json['churchName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$HistoriqueSignaturesModelToJson(
        HistoriqueSignaturesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'nomParoissien': instance.nomParoissien,
      'emailParoissien': instance.emailParoissien,
      'ancienId': instance.ancienId,
      'nomAncien': instance.nomAncien,
      'month': instance.month,
      'year': instance.year,
      'status': instance.status,
      'amount': instance.amount,
      'fees': instance.fees,
      'signatureType': instance.signatureType,
      'location': instance.location,
      'churchId': instance.churchId,
      'churchName': instance.churchName,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'notes': instance.notes,
    };
