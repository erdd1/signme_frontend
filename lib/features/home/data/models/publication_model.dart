import '../../domain/entities/publication_entity.dart';

class PublicationModel extends PublicationEntity {
  const PublicationModel({
    required super.id,
    required super.titre,
    required super.contenu,
    required super.type,
    required super.auteurNom,
    super.auteurPhoto,
    required super.createdAt,
    super.reference,
    super.churchNom,
  });

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    // Auteur peut être dans 'auteur' ou 'user'
    final auteur = json['auteur'] as Map<String, dynamic>?
                ?? json['user'] as Map<String, dynamic>?
                ?? {};

    return PublicationModel(
      id:          (json['id'] as num).toInt(),
      titre:       json['titre']?.toString() ?? json['title']?.toString() ?? '',
      contenu:     json['contenu']?.toString() ?? json['content']?.toString() ?? '',
      type:        json['type']?.toString().toUpperCase() ?? 'ANNONCE',
      auteurNom:   auteur['nom']?.toString() ?? 'Auteur',
      auteurPhoto: auteur['photoUrl']?.toString(),
      createdAt:   DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      reference:   json['reference']?.toString(),
      churchNom:   json['church']?['nom']?.toString(),
    );
  }
}
