// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historique_personnel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoriquePersonnelModel _$HistoriquePersonnelModelFromJson(
        Map<String, dynamic> json) =>
    HistoriquePersonnelModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      nomUtilisateur: json['nomUtilisateur'] as String,
      month: json['month'] as String,
      year: (json['year'] as num).toInt(),
      status: json['status'] as String,
      amount: (json['amount'] as num).toInt(),
      fees: (json['fees'] as num?)?.toInt(),
      signatureType: json['signatureType'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      paymentPhoneNumber: json['paymentPhoneNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$HistoriquePersonnelModelToJson(
        HistoriquePersonnelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'nomUtilisateur': instance.nomUtilisateur,
      'month': instance.month,
      'year': instance.year,
      'status': instance.status,
      'amount': instance.amount,
      'fees': instance.fees,
      'signatureType': instance.signatureType,
      'paymentMethod': instance.paymentMethod,
      'paymentPhoneNumber': instance.paymentPhoneNumber,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };
