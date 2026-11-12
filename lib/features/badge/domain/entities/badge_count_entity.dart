import 'package:equatable/equatable.dart';

/// Entité domaine — Compteurs de badges de notifications
///
/// Représente les compteurs non lus pour chaque onglet/section de l'application.
class BadgeCountEntity extends Equatable {
  const BadgeCountEntity({
    required this.annonces,
    required this.meditations,
    required this.evenements,
    required this.historique,
    required this.historiqueSignatures,
  });

  /// Badge onglet Home (Accueil) — Annonces non lues
  final int annonces;

  /// Badge onglet Home (Accueil) — Méditations non lues
  final int meditations;

  /// Badge onglet Home (Accueil) — Événements non lus
  final int evenements;

  /// Badge onglet Historique — Historique personnel non lu
  final int historique;

  /// Badge drawer Historique Signatures — Signatures effectuées non vues (ancien/pasteur)
  final int historiqueSignatures;

  /// Aucun badge actif
  static const BadgeCountEntity empty = BadgeCountEntity(
    annonces: 0,
    meditations: 0,
    evenements: 0,
    historique: 0,
    historiqueSignatures: 0,
  );

  /// Compteur d'un type de badge (mêmes identifiants que [copyWithZero]).
  int countFor(String type) => switch (type) {
        'annonces' => annonces,
        'meditations' => meditations,
        'evenements' => evenements,
        'historique' => historique,
        'historique_signatures' => historiqueSignatures,
        _ => 0,
      };

  /// Remet un type spécifique à zéro (optimistic update local)
  BadgeCountEntity copyWithZero(String type) {
    return BadgeCountEntity(
      annonces: type == 'annonces' ? 0 : annonces,
      meditations: type == 'meditations' ? 0 : meditations,
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
      'BadgeCountEntity(annonces: $annonces, '
      'meditations: $meditations, '
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
      [annonces, meditations, evenements, historique, historiqueSignatures];
}
