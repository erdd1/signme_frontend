import '../../domain/entities/evenement_entity.dart';

class EvenementModel {
  const EvenementModel({
    required this.uuid,
    required this.titre,
    required this.description,
    this.imageUrl,
    required this.statut,
    required this.dateDebut,
    this.dateFin,
    this.publishedAt,
    this.scheduledPublishAt,
    this.termineAt,
    this.archivedAt,
    this.objectifMontant,
    this.montantCollecte = 0,
    this.nombreContributions = 0,
    this.nombreContributeurs,
    this.pourcentageObjectif,
    this.joursAvantArchivage,
    required this.auteurId,
    required this.auteurNom,
    this.auteurPhotoUrl,
    this.churchId,
    this.churchNom,
    this.estAuteur = false,
    this.peutContribuer = false,
    this.peutGerer = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uuid;
  final String titre;
  final String description;
  final String? imageUrl;
  final String statut;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final DateTime? publishedAt;
  final DateTime? scheduledPublishAt;
  final DateTime? termineAt;
  final DateTime? archivedAt;
  final int? objectifMontant;
  final int montantCollecte;
  final int nombreContributions;
  final int? nombreContributeurs;
  final double? pourcentageObjectif;
  final int? joursAvantArchivage;
  final int auteurId;
  final String auteurNom;
  final String? auteurPhotoUrl;
  final int? churchId;
  final String? churchNom;
  final bool estAuteur;
  final bool peutContribuer;
  final bool peutGerer;
  final DateTime createdAt;
  final DateTime updatedAt;

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  factory EvenementModel.fromJson(Map<String, dynamic> json) {
    final auteur = json['auteur'] as Map<String, dynamic>?;
    final church = json['church'] as Map<String, dynamic>?;

    return EvenementModel(
      uuid: json['uuid'].toString(),
      titre: (json['titre'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
      statut: (json['statut'] ?? 'brouillon').toString(),
      dateDebut: _tryParseDate(json['dateDebut']) ?? DateTime.now(),
      dateFin: _tryParseDate(json['dateFin']),
      publishedAt: _tryParseDate(json['publishedAt']),
      scheduledPublishAt: _tryParseDate(json['scheduledPublishAt']),
      termineAt: _tryParseDate(json['termineAt']),
      archivedAt: _tryParseDate(json['archivedAt']),
      objectifMontant: json['objectifMontant'] == null
          ? null
          : _asInt(json['objectifMontant']),
      montantCollecte: _asInt(json['montantCollecte']),
      nombreContributions: _asInt(json['nombreContributions']),
      nombreContributeurs: json['nombreContributeurs'] == null ? null : _asInt(json['nombreContributeurs']),
      pourcentageObjectif: (json['pourcentageObjectif'] as num?)?.toDouble(),
      joursAvantArchivage: json['joursAvantArchivage'] == null
          ? null
          : _asInt(json['joursAvantArchivage']),
      auteurId: _asInt(auteur?['id'] ?? json['auteurId']),
      auteurNom: (auteur?['nom'] ?? json['auteurNom'] ?? 'Anonyme').toString(),
      auteurPhotoUrl: (auteur?['photoUrl'] ?? json['auteurPhotoUrl'])?.toString(),
      churchId: church?['id'] == null ? null : _asInt(church?['id']),
      churchNom: (church?['nom'] ?? json['churchNom'])?.toString(),
      estAuteur: json['estAuteur'] == true,
      peutContribuer: json['peutContribuer'] == true,
      peutGerer: json['peutGerer'] == true,
      createdAt: _tryParseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _tryParseDate(json['updatedAt']) ?? DateTime.now(),
    );
  }

  EvenementEntity toEntity() => EvenementEntity(
        uuid: uuid,
        titre: titre,
        description: description,
        imageUrl: imageUrl,
        statut: statut,
        dateDebut: dateDebut,
        dateFin: dateFin,
        publishedAt: publishedAt,
        scheduledPublishAt: scheduledPublishAt,
        termineAt: termineAt,
        archivedAt: archivedAt,
        objectifMontant: objectifMontant,
        montantCollecte: montantCollecte,
        nombreContributions: nombreContributions,
        nombreContributeurs: nombreContributeurs,
        pourcentageObjectif: pourcentageObjectif,
        joursAvantArchivage: joursAvantArchivage,
        auteur: EvenementAuteur(id: auteurId, nom: auteurNom, photoUrl: auteurPhotoUrl),
        church: EvenementChurch(id: churchId, nom: churchNom),
        estAuteur: estAuteur,
        peutContribuer: peutContribuer,
        peutGerer: peutGerer,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
