import 'package:isar/isar.dart';
import '../../../features/publications/domain/entities/publication_entity.dart';

part 'publication_isar_model.g.dart';

/// Collection Isar pour les publications — cache local Offline-First.
///
/// Chaque publication est stockée individuellement avec son [serverId]
/// (= id backend) comme index unique. Permet les requêtes par [type] et
/// tri par [updatedAt] pour la sync delta.
@collection
class PublicationIsarModel {
  Id id = Isar.autoIncrement;

  /// ID côté backend (unique, sert à l'upsert lors de la sync).
  @Index(unique: true, replace: true)
  int serverId = 0;

  String titre    = '';
  String contenu  = '';
  String type     = 'annonce'; // 'annonce' | 'meditation'

  @Index()
  String? referenceBiblique;

  int    auteurId       = 0;
  String auteurNom      = '';
  String? auteurPhotoUrl;
  int    churchId       = 0;
  String? churchName;

  DateTime date      = DateTime.now();
  DateTime createdAt = DateTime.now();

  @Index()
  DateTime updatedAt = DateTime.now();

  // ── Conversions ─────────────────────────────────────────────────────────

  PublicationEntity toEntity() => PublicationEntity(
        id:               serverId,
        titre:            titre,
        contenu:          contenu,
        type:             type,
        referenceBiblique: referenceBiblique,
        auteurId:         auteurId,
        auteurNom:        auteurNom,
        auteurPhotoUrl:   auteurPhotoUrl,
        churchId:         churchId,
        churchName:       churchName,
        date:             date,
        createdAt:        createdAt,
        updatedAt:        updatedAt,
      );

  static PublicationIsarModel fromEntity(PublicationEntity e) {
    return PublicationIsarModel()
      ..serverId          = e.id
      ..titre             = e.titre
      ..contenu           = e.contenu
      ..type              = e.type
      ..referenceBiblique = e.referenceBiblique
      ..auteurId          = e.auteurId
      ..auteurNom         = e.auteurNom
      ..auteurPhotoUrl    = e.auteurPhotoUrl
      ..churchId          = e.churchId
      ..churchName        = e.churchName
      ..date              = e.date
      ..createdAt         = e.createdAt
      ..updatedAt         = e.updatedAt;
  }
}
