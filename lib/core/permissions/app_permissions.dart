import '../../features/auth/domain/entities/auth_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  RBAC — Permissions par rôle EEC SignCard
//
//  Rôles :
//    administrateur → accès total
//    pasteur        → finances, historique global, signature présentielle
//    tresorier      → finances, historique global (lecture)
//    secretaire     → gestion membres, publications
//    ancien         → signature présentielle (si estDeService), historique groupe
//    paroissien     → ma carte, signature distance, historique personnel
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppPermissions {

  // ── Accès aux modules ───────────────────────────────────────────────────────

  /// Voir le module Finances (rapport annuel, comparaison)
  static bool canViewFinances(UserEntity u) =>
      u.isAdmin || u.isPasteur || u.isTresorier;

  /// Voir l'historique de TOUS les membres (pas seulement le sien)
  static bool canViewAllHistorique(UserEntity u) =>
      u.isAdmin || u.isPasteur || u.isTresorier;

  /// Voir l'historique de son groupe seulement
  static bool canViewGroupHistorique(UserEntity u) =>
      u.isAncien;

  /// Initier une signature à distance (Mobile Money via Campay)
  static bool canSignDistance(UserEntity u) => u.actif;

  /// Enregistrer une signature présentielle pour un autre membre
  static bool canSignPresentiel(UserEntity u) =>
      u.actif && (u.isAdmin || u.isPasteur || (u.isAncien && u.estDeService));

  /// Voir la liste complète des publications (accès à la section Home)
  static bool canViewPublications(UserEntity u) => true; // tous les rôles

  /// Gérer les publications (créer, modifier, supprimer)
  static bool canManagePublications(UserEntity u) =>
      u.isAdmin || u.isPasteur || u.isSecretaire;

  /// Voir la liste des membres de l'église
  static bool canViewMembers(UserEntity u) =>
      u.isAdmin || u.isPasteur || u.isSecretaire;

  /// Désigner / révoquer un ancien
  static bool canManageAnciens(UserEntity u) =>
      u.isAdmin || u.isPasteur;

  /// Accès à la section Ma Carte (propre carte)
  static bool canViewMaCarte(UserEntity u) => true; // tous les rôles

  /// Accès aux rapports financiers détaillés
  static bool canViewRapports(UserEntity u) =>
      u.isAdmin || u.isPasteur || u.isTresorier;

  // ── Navigation Bottom Bar ──────────────────────────────────────────────────

  /// Retourne les onglets de navigation visibles pour ce rôle
  static List<NavTab> getNavTabs(UserEntity u) {
    final tabs = <NavTab>[];

    tabs.add(NavTab.home);          // Tout le monde voit l'accueil

    if (canViewFinances(u)) {
      tabs.add(NavTab.finances);    // Seulement admin/pasteur/trésorier
    }

    tabs.add(NavTab.historique);    // Tout le monde voit l'historique
    tabs.add(NavTab.maCarte);       // Tout le monde voit sa carte

    return tabs;
  }

  // ── Labels rôle ───────────────────────────────────────────────────────────
  static String roleLabel(String role) {
    const map = {
      'administrateur': 'ADMINISTRATEUR',
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
      'Contactez votre administrateur si vous pensez que c\'est une erreur.';
}

// ── Enum des onglets de navigation ────────────────────────────────────────────
enum NavTab { home, finances, historique, maCarte }
