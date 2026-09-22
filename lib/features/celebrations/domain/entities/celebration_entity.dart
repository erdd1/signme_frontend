/// Célébration — instance générée côté serveur pour l'utilisateur connecté
/// (anniversaire ou l'une des 8 occasions calendaires). `type` correspond
/// exactement aux clés App\Models\CelebrationType::KEY_* côté backend.
class CelebrationEntity {
  const CelebrationEntity({
    required this.uuid,
    required this.type,
    required this.label,
    required this.titre,
    required this.message,
    required this.animationKey,
    required this.occursOn,
    required this.isRead,
    this.readAt,
  });

  final String uuid;
  final String type;
  final String label;
  final String titre;
  final String message;
  final String animationKey;
  final String occursOn;
  final bool isRead;
  final String? readAt;

  factory CelebrationEntity.fromJson(Map<String, dynamic> json) {
    return CelebrationEntity(
      uuid: json['uuid']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      titre: json['titre']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      animationKey: json['animationKey']?.toString() ?? 'birthday',
      occursOn: json['occursOn']?.toString() ?? '',
      isRead: json['isRead'] == true,
      readAt: json['readAt']?.toString(),
    );
  }

  CelebrationEntity copyWith({bool? isRead, String? readAt}) => CelebrationEntity(
        uuid: uuid,
        type: type,
        label: label,
        titre: titre,
        message: message,
        animationKey: animationKey,
        occursOn: occursOn,
        isRead: isRead ?? this.isRead,
        readAt: readAt ?? this.readAt,
      );
}
