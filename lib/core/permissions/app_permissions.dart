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

  /// Initier une signature à distance (Mobile Money ou carte via NotchPay)
  static bool canSignDistance(UserEntity u) => u.actif;

  /// Enregistrer une signature présentielle pour un autre membre
  static bool canSignPresentiel(UserEntity u) =>
      u.actif && (u.isPasteur || (u.isAncien && u.estDeService));

  /// Voir la liste complète des publications (accès à la section Home)
  static bool canViewPublications(UserEntity u) => true; // tous les rôles

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

  /// Accès à la section Ma Carte (propre carte)
  static bool canViewMaCarte(UserEntity u) => true; // tous les rôles

  /// Accès aux rapports financiers détaillés
  static bool canViewRapports(UserEntity u) =>
      u.isPasteur || u.isTresorier;

  /// Gérer les événements (créer, modifier, publier, terminer, archiver)
  static bool canManageEvenements(UserEntity u) =>
      u.isPasteur || u.isSecretaire;

  /// Voir l'onglet drawer "Contributions événement" (vue trésorerie)
  static bool canViewContributionsEvenement(UserEntity u) =>
      u.isPasteur || u.isSecretaire || u.isTresorier;

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

  // ── Description de l'accès refusé ─────────────────────────────────────────
  static String accessDeniedMessage(String module) =>
      'Vous n\'avez pas accès au module $module.\n'
      'Contactez votre pasteur ou secrétaire si vous pensez que c\'est une erreur.';
}

// ── Enum des onglets de navigation ────────────────────────────────────────────
enum NavTab { home, finances, historique, profile, maCarte }
