/// SIGNME Assets Constants
/// Centralizes all asset paths to avoid hardcoded strings in UI.
abstract final class SignmeAssets {
  static const String _imagesBase = 'assets/images';
  static const String _iconsBase = 'assets/icones';

  // --- SVG Onboarding ---
  static const String onboardingSigner = '$_imagesBase/unboarding_signer.svg';
  static const String onboardingAnnonce = '$_imagesBase/unboarding_annonce.svg';
  static const String onboardingUsers = '$_imagesBase/unboarding_gerer_utilisateur.svg';
  static const String onboardingProfile = '$_imagesBase/unboarding_profil.svg';
  static const String onboardingAnciens = '$_imagesBase/unboarding_ancien_service.svg';
  static const String onboardingHistorique = '$_imagesBase/unboarding_historique.svg';
  static const String onboardingHome = '$_imagesBase/unboarding_home.svg';

  /// Image par défaut d'un événement sans image choisie par l'auteur.
  static const String evenementDefault = onboardingAnnonce;

  // --- Icons & Images ---
  static const String logo = '$_iconsBase/logo_signme.png';
  static const String lock = '$_imagesBase/lock.png';
  static const String email = '$_imagesBase/email.png';
  static const String google = '$_imagesBase/google.png';
  static const String facebook = '$_imagesBase/facebook.png';
  static const String search = '$_imagesBase/recherche.png';
  static const String add = '$_imagesBase/add.png';
  static const String logout = '$_imagesBase/deconnexion.png';
  static const String eeclogo = '$_iconsBase/eeclogo.jpg';
  static const String whatsapp = '$_iconsBase/whatsapp.png';
  
  // --- Menu Drawer Icons ---
  static const String finances = '$_imagesBase/finances.png';
  static const String manageUsers = '$_imagesBase/gerer_utilisateurs.png';
  static const String serviceAnciens = '$_imagesBase/ancien_service.png';
  static const String settings = '$_imagesBase/parametres.png';
}
