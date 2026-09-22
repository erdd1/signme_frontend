import 'package:equatable/equatable.dart';

/// Entité domaine — Compteurs de badges de notifications
///
/// Représente les compteurs non lus pour chaque onglet/section de l'application.
class BadgeCountEntity extends Equatable {
  const BadgeCountEntity({
    required this.publications,
    required this.evenements,
    required this.historique,
    required this.historiqueSignatures,
  });

  /// Badge onglet Home (Accueil) — Publications non lues
  final int publications;

  /// Badge onglet Home (Accueil) — Événements non lus (combiné avec publications)
  final int evenements;

  /// Badge onglet Historique — Historique personnel non lu
  final int historique;

  /// Badge drawer Historique Signatures — Signatures effectuées non vues (ancien/pasteur)
  final int historiqueSignatures;

  /// Aucun badge actif
  static const BadgeCountEntity empty = BadgeCountEntity(
    publications: 0,
    evenements: 0,
    historique: 0,
    historiqueSignatures: 0,
  );

  /// Remet un type spécifique à zéro (optimistic update local)
  BadgeCountEntity copyWithZero(String type) {
    return BadgeCountEntity(
      publications: type == 'publications' ? 0 : publications,
      evenements: type == 'evenements' ? 0 : evenements,
      historique: type == 'historique' ? 0 : historique,
      historiqueSignatures:
          type == 'historique_signatures' ? 0 : historiqueSignatures,
    );
  }

  /// Texte affiché dans le badge : 1-9 → chiffre, 10+ → "9+"
  static String formatCount(int count) {
    if (count <= 0) return '';
    if (count > 9) return '9+';
    return '$count';
  }

  @override
  String toString() =>
      'BadgeCountEntity(publications: $publications, '
      'evenements: $evenements, '
      'historique: $historique, '
      'historiqueSignatures: $historiqueSignatures)';

  // Sans égalité par valeur, chaque refresh() (polling 60s, toute la
  // session) produisait une NOUVELLE instance considérée "différente" par
  // défaut (égalité par identité) même à compteurs inchangés — Riverpod
  // notifiait alors ses écouteurs à chaque cycle, forçant un rebuild complet
  // de MainShell (AppBar + Drawer + navbar avec flou BackdropFilter, l'un
  // des rendus les plus coûteux de Flutter) toutes les 60 secondes, sans
  // interruption, pour chaque utilisateur connecté.
  @override
  List<Object?> get props =>
      [publications, evenements, historique, historiqueSignatures];
}
