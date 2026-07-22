import 'package:isar/isar.dart';
import '../../../features/evenements/domain/entities/evenement_entity.dart';

part 'evenement_isar_model.g.dart';

/// Collection Isar pour les événements (module collecte de fonds) — cache
/// local Offline-First.
///
/// L'identifiant serveur est un UUID (pas un entier) : l'index unique porte
/// donc sur [serverUuid]. Aucune suppression n'est jamais exposée côté
/// backend pour les événements, donc pas de mécanisme de purge par delta ici
/// (contrairement aux publications) — seuls les upserts sont nécessaires.
@collection
class EvenementIsarModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverUuid;

  String titre = '';
  String description = '';
  String? imageUrl;

  @Index()
  String statut = 'brouillon';

  DateTime dateDebut = DateTime.now();
  DateTime? dateFin;
  DateTime? publishedAt;
  DateTime? scheduledPublishAt;
  DateTime? termineAt;
  DateTime? archivedAt;

  int? objectifMontant;
  int montantCollecte = 0;
  int nombreContributions = 0;
  double? pourcentageObjectif;
  int? joursAvantArchivage;

  int auteurId = 0;
  String auteurNom = '';
  String? auteurPhotoUrl;
  int? churchId;
  String? churchNom;

  bool estAuteur = false;
  bool peutContribuer = false;
  bool peutGerer = false;

  DateTime createdAt = DateTime.now();

  @Index()
  DateTime updatedAt = DateTime.now();

  // ── Conversions ─────────────────────────────────────────────────────────

  EvenementEntity toEntity() => EvenementEntity(
        uuid: serverUuid,
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

  static EvenementIsarModel fromEntity(EvenementEntity e) {
    return EvenementIsarModel()
      ..serverUuid = e.uuid
      ..titre = e.titre
      ..description = e.description
      ..imageUrl = e.imageUrl
      ..statut = e.statut
      ..dateDebut = e.dateDebut
      ..dateFin = e.dateFin
      ..publishedAt = e.publishedAt
      ..scheduledPublishAt = e.scheduledPublishAt
      ..termineAt = e.termineAt
      ..archivedAt = e.archivedAt
      ..objectifMontant = e.objectifMontant
      ..montantCollecte = e.montantCollecte
      ..nombreContributions = e.nombreContributions
      ..pourcentageObjectif = e.pourcentageObjectif
      ..joursAvantArchivage = e.joursAvantArchivage
      ..auteurId = e.auteur.id
      ..auteurNom = e.auteur.nom
      ..auteurPhotoUrl = e.auteur.photoUrl
      ..churchId = e.church.id
      ..churchNom = e.church.nom
      ..estAuteur = e.estAuteur
      ..peutContribuer = e.peutContribuer
      ..peutGerer = e.peutGerer
      ..createdAt = e.createdAt
      ..updatedAt = e.updatedAt;
  }
}
