import 'package:equatable/equatable.dart';

class SignatureEntity extends Equatable {
  const SignatureEntity({
    required this.id,
    required this.userId,
    required this.nomParoissien,
    required this.month,
    required this.year,
    required this.monthIndex,
    required this.amount,
    required this.fees,
    required this.signatureType,
    required this.status,
    this.ancienNom,
    this.campayReference,
    this.paymentMethod,
    this.phoneNumber,
    this.createdAt,
  });

  final int     id;
  final int     userId;
  final String  nomParoissien;
  final String  month;       // YYYY-MM
  final int     year;
  final int     monthIndex;  // 0..11
  final int     amount;
  final int     fees;
  final String  signatureType; // presentiel | distance
  final String  status;        // pending | completed | failed
  final String? ancienNom;
  final String? campayReference;
  final String? paymentMethod;
  final String? phoneNumber;
  final DateTime? createdAt;

  bool get isPending   => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed    => status == 'failed';
  bool get isDistance  => signatureType == 'distance';
  bool get isPresentiel => signatureType == 'presentiel';

  int get totalWithFees => amount + fees;

  @override
  List<Object?> get props => [id, month, status];
}

/// Structure retournée par /api/v1/signatures/ma-carte
class MaCarteData {
  const MaCarteData({
    required this.userId,
    required this.year,
    required this.signaturesParMois,
    required this.totalAmount,
    required this.totalSignatures,
    required this.hasPendingSignature,
  });

  final int    userId;
  final int    year;
  final Map<String, SignatureEntity?> signaturesParMois; // "0".."11" → Signature ou null
  final int    totalAmount;
  final int    totalSignatures;
  final bool   hasPendingSignature;

  factory MaCarteData.fromJson(Map<String, dynamic> json) {
    // Le backend retourne la structure : { 'year': ..., 'carte': [...], ... }
    final months = <String, SignatureEntity?>{};
    final carte = json['carte'] as List? ?? json['signatures'] as List? ?? [];

    for (int i = 0; i < 12; i++) {
      months[i.toString()] = null;
    }

    for (final item in carte) {
      final itemMap = item as Map<String, dynamic>;
      final monthIndex = (itemMap['monthIndex'] as num?)?.toInt() ?? 0;
      final signatureData = itemMap['signature'] as Map<String, dynamic>?;
      
      if (signatureData != null) {
        // Créer une signature à partir des données embéquées
        final sig = _SignaturePlain.fromJson(signatureData);
        months[monthIndex.toString()] = sig;
      }
    }

    return MaCarteData(
      userId:             (json['userId'] as num?)?.toInt() ?? 0,
      year:               (json['year']   as num?)?.toInt() ?? DateTime.now().year,
      signaturesParMois:  months,
      totalAmount:        (json['montant_total'] as num?)?.toInt() ?? (json['total_amount'] as num?)?.toInt() ?? 0,
      totalSignatures:    (json['total_signe'] as num?)?.toInt() ?? (json['total_signatures'] as num?)?.toInt() ?? 0,
      hasPendingSignature: json['has_pending'] as bool? ?? false,
    );
  }
}

class _SignaturePlain extends SignatureEntity {
  const _SignaturePlain({
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
    super.campayReference,
    super.paymentMethod,
    super.phoneNumber,
    super.createdAt,
  });

  factory _SignaturePlain.fromJson(Map<String, dynamic> j) => _SignaturePlain(
    id:            (j['id'] as num?)?.toInt() ?? 0,
    userId:        (j['userId'] as num?)?.toInt() ?? 0,
    nomParoissien: j['nomParoissien']?.toString() ?? '',
    month:         j['month']?.toString() ?? '',
    year:          (j['year'] as num?)?.toInt() ?? 0,
    monthIndex:    (j['monthIndex'] as num?)?.toInt() ?? 0,
    amount:        (j['amount'] as num?)?.toInt() ?? 0,
    fees:          (j['fees']   as num?)?.toInt() ?? 0,
    signatureType: j['signatureType']?.toString() ?? 'presentiel',
    status:        j['status']?.toString() ?? 'completed',
    ancienNom:     j['ancienNom']?.toString(),
    campayReference: j['campay_reference']?.toString(),
    paymentMethod: j['paymentMethod']?.toString(),
    phoneNumber:   j['phoneNumber']?.toString(),
    createdAt:     DateTime.tryParse(j['created_at']?.toString() ?? j['signed_at']?.toString() ?? ''),
  );
}
