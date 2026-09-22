class RetraitBeneficiaireEntity {
  const RetraitBeneficiaireEntity({
    required this.uuid,
    required this.operator,
    required this.channel,
    required this.numeroMasque,
    required this.createdAt,
  });

  final String uuid;
  final String operator; // 'Orange Money' | 'MTN Mobile Money'
  final String channel;  // 'cm.orange' | 'cm.mtn'
  final String numeroMasque;
  final String createdAt;

  factory RetraitBeneficiaireEntity.fromJson(Map<String, dynamic> json) {
    return RetraitBeneficiaireEntity(
      uuid: json['uuid']?.toString() ?? '',
      operator: json['operator']?.toString() ?? '',
      channel: json['channel']?.toString() ?? '',
      numeroMasque: json['numeroMasque']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
