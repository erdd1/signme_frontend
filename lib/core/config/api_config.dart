import 'app_environment.dart';

/// Endpoints de l'API EEC SignCard (chemins relatifs à [baseUrl]).
abstract final class ApiConfig {
  static String get baseUrl => AppEnvironment.apiBaseUrl;

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyPasswordResetOTP = '/auth/verify-password-reset-otp';
  static const String resendPasswordResetOTP = '/auth/resend-password-reset-otp';
  static const String confirmPasswordReset = '/auth/confirm-password-reset';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String refreshToken = '/auth/refresh';

  // ── Signatures ────────────────────────────────────────────────────────────
  static const String signatureDistance = '/signatures/distance';
  static const String signaturePresentiel = '/signatures/presentiel';
  static const String signatureMaCarte = '/signatures/ma-carte';
  static const String signatureHistorique = '/signatures/historique';
  static const String signatureFees = '/signatures/fees';
  static String signatureTransactionStatus(int transactionId) =>
      '/signatures/transaction/$transactionId/status';
  static String signatureMemberStatus(int userId) =>
      '/signatures/members/$userId/status';

  // ── Publications ──────────────────────────────────────────────────────────
  static const String publications = '/publications';

  // ── Evenements (module collecte de fonds) ──────────────────────────────────
  static const String evenements = '/evenements';
  static const String evenementsGestion = '/evenements/gestion';
  static String evenementDetail(String uuid) => '/evenements/$uuid';
  static String evenementPublish(String uuid) => '/evenements/$uuid/publish';
  static String evenementCancelScheduled(String uuid) =>
      '/evenements/$uuid/cancel-scheduled';
  static String evenementTerminer(String uuid) => '/evenements/$uuid/terminer';
  static String evenementArchiver(String uuid) => '/evenements/$uuid/archiver';
  static String evenementDesarchiver(String uuid) =>
      '/evenements/$uuid/desarchiver';
  static String evenementContributions(String uuid) =>
      '/evenements/$uuid/contributions';
  static String contributionStatus(String uuid) =>
      '/contributions/transaction/$uuid/status';
  static const String contributionsEvenements = '/contributions-evenements';
  static const String contributionsEvenementsStats = '/contributions-evenements/stats';
  static const String contributionsEvenementsFilterEvents = '/contributions-evenements/filters/events';
  static const String contributionsEvenementsExportPdf = '/contributions-evenements/export-pdf';


  // ── Mes contributions (module "Mes dépenses") ──────────────────────────────
  static const String mesContributions = '/mes-contributions';
  static const String mesContributionsStats = '/mes-contributions/stats';

  // ── Rapports ──────────────────────────────────────────────────────────────
  static const String rapportAnnuel = '/rapports/finances/annuel';
  static const String rapportMensuel = '/rapports/finances/mois';
  static const String rapportComparaison = '/rapports/comparaison';
  static const String rapportSecretaire = '/rapports/secretaire';
  static const String rapportSecretairePdf = '/rapports/secretaire/pdf';
  static const String rapportAnnuelPdf = '/rapports/finances/annuel/pdf';

  // ── Users ─────────────────────────────────────────────────────────────────
  static const String users = '/users';
  static String userPhoto(int userId) => '/users/$userId/photo';
  static const String usersPasteur = '/users/paroissiens';
  static const String usersStats = '/users/stats';
  static const String usersNextMatricule = '/users/next-matricule';
  static const String usersExportPdf = '/users/export-pdf';

  // ── Listes gérées (champs démographiques users) ────────────────────────────
  static const String groupes = '/groupes';
  static String groupeDetail(int id) => '/groupes/$id';
  static const String quartiers = '/quartiers';
  static String quartierDetail(int id) => '/quartiers/$id';
  static const String villes = '/villes';
  static String villeDetail(int id) => '/villes/$id';

  // ── Anciens ───────────────────────────────────────────────────────────────
  static const String ancienDesignations = '/anciens-designations';

  // ── Paiements ─────────────────────────────────────────────────────────────
  static const String payments = '/payments';

  // ── Notifications / Badges ────────────────────────────────────────────────
  static const String notifications             = '/notifications';
  static const String notificationBadges        = '/notifications/badges';
  static const String notificationBadgesMarkRead = '/notifications/badges/mark-read';

  // ── Support ───────────────────────────────────────────────────────────────
  static const String supportWhatsapp = '/support/whatsapp';

  // ── Notifications push (FCM) ────────────────────────────────────────────────
  static const String deviceTokens = '/device-tokens';

  // ── Célébrations (anniversaires + occasions calendaires) ───────────────────
  static const String celebrations = '/celebrations';
  static String celebrationDetail(String uuid) => '/celebrations/$uuid';
  static String celebrationMarkRead(String uuid) => '/celebrations/$uuid/read';
}
