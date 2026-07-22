// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicationModel _$PublicationModelFromJson(Map<String, dynamic> json) =>
    PublicationModel(
      id: (json['id'] as num).toInt(),
      titre: json['titre'] as String,
      contenu: json['contenu'] as String,
      type: json['type'] as String,
      referenceBiblique: json['referenceBiblique'] as String?,
      auteurId: (json['auteurId'] as num).toInt(),
      auteurNom: json['auteurNom'] as String,
      auteurPhotoUrl: json['auteurPhotoUrl'] as String?,
      churchId: (json['churchId'] as num).toInt(),
      churchName: json['churchName'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PublicationModelToJson(PublicationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titre': instance.titre,
      'contenu': instance.contenu,
      'type': instance.type,
      'referenceBiblique': instance.referenceBiblique,
      'auteurId': instance.auteurId,
      'auteurNom': instance.auteurNom,
      'auteurPhotoUrl': instance.auteurPhotoUrl,
      'churchId': instance.churchId,
      'churchName': instance.churchName,
      'date': instance.date.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
