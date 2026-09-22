import '../../features/auth/domain/entities/user_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  RBAC — Permissions par rôle EEC SignCard
//
//  Rôles (application mobile uniquement — l'administrateur a sa propre
//  interface web séparée et ne peut pas s'authentifier ici) :
//    pasteur        → finances, historique global, signature présentielle, activation/désactivation comptes
//    tresorier      → finances, historique global (lecture)
//    secretaire     → gestion membres (créer/modifier), publications — ⚠ pas d'activation/désactivation
//    ancien         → signature présentielle (si estDeService), historique groupe
//    paroissien     → ma carte, signature distance, historique personnel
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppPermissions {

  // ── Accès aux modules ───────────────────────────────────────────────────────

  /// Voir le module Finances (rapport annuel, comparaison)
  static bool canViewFinances(UserEntity u) =>
      u.isPasteur || u.isTresorier;

  /// Voir l'historique de TOUS les membres (pas seulement le sien)
  static bool canViewAllHistorique(UserEntity u) =>
      u.isPasteur || u.isTresorier;

  /// Voir l'historique de son groupe seulement
  static bool canViewGroupHistorique(UserEntity u) =>
      u.isAncien;

  /// Initier une signature à distance (Mobile Money ou carte via NotchPay) —
  /// bloqué pour un paroissien non communiant.
  static bool canSignDistance(UserEntity u) => u.actif && u.estCommuniant;

  /// Enregistrer une signature présentielle pour un autre membre
  static bool canSignPresentiel(UserEntity u) =>
      u.actif && (u.isPasteur || (u.isAncien && u.estDeService));

  /// Voir la liste complète des publications (accès à la section Home)
  static bool canViewPublications(UserEntity u) => true; // tous les rôles

  /// Voir les publications de type méditation — bloqué pour un paroissien
  /// non communiant (il garde accès aux annonces).
  static bool canViewMeditations(UserEntity u) => u.estCommuniant;

  /// Gérer les publications (créer, modifier, supprimer)
  static bool canManagePublications(UserEntity u) =>
      u.isPasteur || u.isSecretaire;

  /// Modifier une publication (auteur uniquement)
  static bool canEditPublication(UserEntity u, int auteurId) =>
      canManagePublications(u) && u.id == auteurId;

  /// Supprimer (auteur ou pasteur)
  static bool canDeletePublication(UserEntity u, int auteurId) =>
      canManagePublications(u) && (u.isPasteur || u.id == auteurId);

  /// Voir la liste des membres de l'église
  static bool canViewMembers(UserEntity u) =>
      u.isPasteur || u.isSecretaire;

  /// Créer / gérer les membres (pasteur, secrétaire)
  static bool canManageMembers(UserEntity u) =>
      u.isPasteur || u.isSecretaire;

  /// Modifier le rôle d'un membre (réservé au pasteur)
  static bool canEditMemberRole(UserEntity u) => u.isPasteur;

  /// Activer / désactiver un compte membre.
  /// Réservé au pasteur — la secrétaire n'a pas ce droit.
  static bool canToggleMemberStatus(UserEntity u, {required int targetId}) =>
      u.isPasteur && u.id != targetId;

  /// Désigner / révoquer un ancien
  static bool canManageAnciens(UserEntity u) => u.isPasteur;

  /// Modifier sa propre photo (uniquement pasteur).
  static bool canChangeOwnProfilePhoto(UserEntity u) => u.isPasteur;

  /// Importer / modifier la photo d'un autre membre (création ou édition).
  static bool canUploadMemberPhoto(UserEntity actor, {required int targetUserId}) {
    if (actor.id == targetUserId) return canChangeOwnProfilePhoto(actor);
    return canManageMembers(actor);
  }

  /// Accès à la section Ma Carte (propre carte) — bloqué pour un paroissien
  /// non communiant (il ne peut pas signer, donc pas de carte à consulter).
  static bool canViewMaCarte(UserEntity u) => u.estCommuniant;

  /// Accès à l'historique personnel des signatures (distance + présentiel
  /// reçues) — bloqué pour un paroissien non communiant.
  static bool canViewHistoriquePersonnel(UserEntity u) => u.estCommuniant;

  /// Accès aux rapports financiers détaillés
  static bool canViewRapports(UserEntity u) =>
      u.isPasteur || u.isTresorier;

  /// Télécharger le PDF du rapport secrétaire (qui a signé / qui n'a pas
  /// signé, montant collecté) — pasteur/secrétaire uniquement.
  static bool canDownloadRapportSecretairePdf(UserEntity u) =>
      u.isPasteur || u.isSecretaire;

  /// Gérer les événements (créer, modifier, publier, terminer, archiver)
  static bool canManageEvenements(UserEntity u) =>
      u.isPasteur || u.isSecretaire;

  /// Voir l'onglet drawer "Contributions événement" (vue trésorerie)
  static bool canViewContributionsEvenement(UserEntity u) =>
      u.isPasteur || u.isSecretaire || u.isTresorier;

  /// Télécharger le PDF des contributions événement — pasteur/trésorier
  /// uniquement (le secrétaire garde l'accès en lecture ci-dessus, mais pas
  /// l'export).
  static bool canDownloadContributionsPdf(UserEntity u) =>
      u.isPasteur || u.isTresorier;

  /// Voir le module Sorties financières (registre des retraits Mobile Money)
  static bool canViewSortiesFinancieres(UserEntity u) =>
      u.isPasteur || u.isTresorier;

  /// Voir/effectuer des retraits d'argent vers Orange Money/MTN Mobile Money
  /// (payout NotchPay) — même règle que les sorties financières.
  static bool canViewRetraits(UserEntity u) =>
      u.isPasteur || u.isTresorier;

  /// Gérer la page "À propos de mon Église" (épingler/désépingler,
  /// créer/modifier/supprimer un article, éditer les infos du Card
  /// principal — district, horaires, activités majeures)
  static bool canManageAboutChurch(UserEntity u) =>
      u.isPasteur || u.isSecretaire;

  // ── Navigation Bottom Bar ──────────────────────────────────────────────────

  /// Retourne les onglets de navigation visibles pour ce rôle
  /// TOUS les rôles voient les mêmes 4 onglets — les autres modules sont dans le drawer
  static List<NavTab> getNavTabs(UserEntity u) {
    final tabs = <NavTab>[];

    tabs.add(NavTab.home);          // Tout le monde voit l'accueil
    tabs.add(NavTab.maCarte);       // Ma Carte — côté gauche du FAB
    tabs.add(NavTab.historique);    // Historique — côté droit du FAB
    tabs.add(NavTab.profile);       // Profil — côté droit du FAB

    // Finances est maintenant dans le drawer, pas dans la navbar

    return tabs;
  }

  // ── Labels rôle ───────────────────────────────────────────────────────────
  static String roleLabel(String role) {
    const map = {
      'pasteur':        'PASTEUR',
      'secretaire':     'SECRÉTAIRE',
      'tresorier':      'TRÉSORIER',
      'ancien':         'ANCIEN',
      'paroissien':     'PAROISSIEN',
    };
    return map[role] ?? role.toUpperCase();
  }

  // ── Statut communiant ────────────────────────────────────────────────────

  /// Message affiché à un paroissien non communiant sur toute fonctionnalité
  /// bloquée (identique au message renvoyé par le backend).
  static const String notCommuniantMessage =
      "Vous ne pouvez pas avoir accès à cette fonctionnalité car vous n'êtes pas communiant.";

  // ── Description de l'accès refusé ─────────────────────────────────────────
  static String accessDeniedMessage(String module) =>
      'Vous n\'avez pas accès au module $module.\n'
      'Contactez votre pasteur ou secrétaire si vous pensez que c\'est une erreur.';
}

// ── Enum des onglets de navigation ────────────────────────────────────────────
enum NavTab { home, finances, historique, profile, maCarte }
