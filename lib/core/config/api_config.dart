/// Endpoints de l'API EEC SignCard (Sanctum)
abstract final class ApiConfig {

  // ── Base URL ─────────────────────────────────────────────────────────────
  /// L'IP WiFi locale : 192.168.1.112 (à adapter selon votre réseau)
  /// En production, utiliser le domaine réel
  static const String baseUrl = 'http://192.168.1.112:8000/api/v1';
  static const String _base   = baseUrl; // alias privé pour les endpoints

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String login         = '$_base/auth/login';
  static const String logout        = '$_base/auth/logout';
  static const String me            = '$_base/auth/me';
  static const String forgotPassword = '$_base/auth/forgot-password';
  static const String refreshToken  = '$_base/auth/refresh';

  // ── Signatures ────────────────────────────────────────────────────────────
  static const String signatureDistance   = '$_base/signatures/distance';
  static const String signaturePresentiel = '$_base/signatures/presentiel';
  static const String signatureMaCarte   = '$_base/signatures/ma-carte';
  static const String signatureHistorique = '$_base/signatures';
  static const String signatureFees       = '$_base/signatures/fees';
  static String signatureTransactionStatus(int transactionId) => '$_base/signatures/transaction/$transactionId/status';
  static String signatureMemberStatus(int userId) => '$_base/signatures/members/$userId/status';

  // ── Publications ──────────────────────────────────────────────────────────
  static const String publications = '$_base/publications';

  // ── Rapports ──────────────────────────────────────────────────────────────
  static const String rapportAnnuel   = '$_base/rapports/annuel';
  static const String rapportMensuel  = '$_base/rapports/mensuel';

  // ── Users / Membres ───────────────────────────────────────────────────────
  static const String users          = '$_base/users';
  static const String usersPasteur   = '$_base/users/paroissiens';

  // ── Anciennes désignations ────────────────────────────────────────────────
  static const String ancienDesignations = '$_base/anciens-designations';

  // ── Paiements ─────────────────────────────────────────────────────────────
  static const String payments = '$_base/payments';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = '$_base/notifications';
}
