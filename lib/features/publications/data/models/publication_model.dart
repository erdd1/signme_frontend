import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/publication_entity.dart';

part 'publication_model.g.dart';

@JsonSerializable()
class PublicationModel {
  final int id;
  final String titre;
  final String contenu;
  final String type;
  final String? referenceBiblique;
  final int auteurId;
  final String auteurNom;
  final String? auteurPhotoUrl;
  final int churchId;
  final String? churchName;
  final DateTime date;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  PublicationModel({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.type,
    this.referenceBiblique,
    required this.auteurId,
    required this.auteurNom,
    this.auteurPhotoUrl,
    required this.churchId,
    this.churchName,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    // Robustesse : Gestion des objets imbriqués pour l'auteur (commun en production)
    final auteur = (json['auteur'] as Map<String, dynamic>?) ?? 
                   (json['user'] as Map<String, dynamic>?) ??
                   (json['author'] as Map<String, dynamic>?);

    // Extraction sécurisée des IDs (numérique ou string)
    final id = json['id'] is int 
        ? json['id'] as int 
        : int.tryParse(json['id']?.toString() ?? '') ?? 0;
        
    final auteurIdRaw = json['auteurId'] ?? json['auteur_id'] ?? auteur?['id'];
    final auteurId = auteurIdRaw is int 
        ? auteurIdRaw 
        : int.tryParse(auteurIdRaw?.toString() ?? '') ?? 0;

    final churchIdRaw = json['churchId'] ?? json['church_id'];
    final churchId = churchIdRaw is int 
        ? churchIdRaw 
        : int.tryParse(churchIdRaw?.toString() ?? '') ?? 0;

    return PublicationModel(
      id: id,
      titre: (json['titre'] ?? json['title'] ?? '').toString(),
      contenu: (json['contenu'] ?? json['content'] ?? '').toString(),
      type: (json['type'] ?? 'annonce').toString(),
      referenceBiblique: (json['referenceBiblique'] ?? json['reference_biblique'])?.toString(),
      auteurId: auteurId,
      // On cherche d'abord la clé à plat, puis dans l'objet imbriqué
      auteurNom: (json['auteurNom'] ?? json['auteur_nom'] ?? auteur?['nom'] ?? auteur?['name'] ?? 'Anonyme').toString(),
      auteurPhotoUrl: json['auteurPhotoUrl']?.toString() ?? 
                       json['auteur_photo_url']?.toString() ??
                       auteur?['photo_url']?.toString() ?? 
                       auteur?['photoUrl']?.toString() ??
                       auteur?['photo']?.toString() ??
                       auteur?['avatar']?.toString(),
      churchId: churchId,
      churchName: (json['churchName'] ?? json['church_name'])?.toString(),
      date: _parseDate(json['date']),
      createdAt: _parseDate(json['created_at'] ?? json['date']),
      updatedAt: _parseDate(json['updated_at'] ?? json['created_at'] ?? json['date']),
    );
  }

  Map<String, dynamic> toJson() => _$PublicationModelToJson(this);

  /// Convertir le modèle en Entity
  PublicationEntity toEntity() => PublicationEntity(
    id: id,
    titre: titre,
    contenu: contenu,
    type: type,
    referenceBiblique: referenceBiblique,
    auteurId: auteurId,
    auteurNom: auteurNom,
    auteurPhotoUrl: auteurPhotoUrl,
    churchId: churchId,
    churchName: churchName,
    date: date,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
