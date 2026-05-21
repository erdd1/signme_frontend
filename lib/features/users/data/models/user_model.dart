import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required int id,
    required String nom,
    required String email,
    required String role,
    int? churchId,
    String? churchNom,
    String? photoUrl,
    String? telephone,
    bool actif = true,
    bool estDeService = false,
    String? groupe,
    String? profession,
    String? originaireDe,
  }) : super(
    id: id,
    nom: nom,
    email: email,
    role: role,
    churchId: churchId,
    churchNom: churchNom,
    photoUrl: photoUrl,
    telephone: telephone,
    actif: actif,
    estDeService: estDeService,
    groupe: groupe,
    profession: profession,
    originaireDe: originaireDe,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      churchId: (json['church_id'] as num?)?.toInt(),
      churchNom: json['church']?['nom']?.toString() ?? json['churchNom']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      telephone: json['telephone']?.toString(),
      actif: json['actif'] as bool? ?? true,
      estDeService: json['est_de_service'] as bool? ?? false,
      groupe: json['groupe']?.toString(),
      profession: json['profession']?.toString(),
      originaireDe: json['originaire_de']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'email': email,
    'role': role,
    'church_id': churchId,
    'photo_url': photoUrl,
    'telephone': telephone,
    'actif': actif,
    'est_de_service': estDeService,
    'groupe': groupe,
    'profession': profession,
    'originaire_de': originaireDe,
  };
}
