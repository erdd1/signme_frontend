import '../../domain/entities/signature_entity.dart';

class SignatureModel extends SignatureEntity {
  const SignatureModel({
    required super.id,
    required super.userId,
    required super.nomParoissien,
    required super.month,
    required super.year,
    required super.monthIndex,
    required super.amount,
    required super.fees,
    required super.signatureType,
    required super.status,
    super.ancienNom,
    super.paymentReference,
    super.paymentMethod,
    super.phoneNumber,
    super.createdAt,
  });

  factory SignatureModel.fromJson(Map<String, dynamic> j) => SignatureModel(
    id:             (j['id'] as num).toInt(),
    userId:         (j['userId'] as num?)?.toInt() ?? 0,
    nomParoissien:  j['nomParoissien']?.toString() ?? '',
    month:          j['month']?.toString() ?? '',
    year:           (j['year'] as num?)?.toInt() ?? 0,
    monthIndex:     (j['monthIndex'] as num?)?.toInt() ?? 0,
    amount:         (j['amount'] as num?)?.toInt() ?? 0,
    fees:           (j['fees']   as num?)?.toInt() ?? 0,
    signatureType:  j['signatureType']?.toString() ?? 'presentiel',
    status:         j['status']?.toString() ?? 'completed',
    ancienNom:      j['ancienNom']?.toString(),
    paymentReference: j['payment_reference']?.toString(),
    paymentMethod:  j['paymentMethod']?.toString(),
    phoneNumber:    j['phoneNumber']?.toString(),
    createdAt:      DateTime.tryParse(j['created_at']?.toString() ?? ''),
  );
}
