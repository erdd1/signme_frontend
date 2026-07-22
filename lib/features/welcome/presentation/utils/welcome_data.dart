
import '../../domain/entities/onboarding_entity.dart';

/// Données d'onboarding pour la welcome page
abstract final class WelcomeData {
  static const List<OnboardingEntity> pages = [
    OnboardingEntity(
      id: 0,
      title: 'Signez votre Carte',
      subtitle: 'En toute Sécurité',
      description:
          'Signez votre carte de sainte cène en quelques secondes avec votre signature numérique sécurisée et confidentielle.',
      imagePath: 'assets/images/unboarding_signer.svg',
    ),
    OnboardingEntity(
      id: 1,
      title: 'Annonces Communautaires',
      subtitle: 'Restez Connecté',
      description:
          'Recevez les dernières annonces et événements de votre communauté religieuse en temps réel.',
      imagePath: 'assets/images/unboarding_annonce.svg',
    ),
    OnboardingEntity(
      id: 2,
      title: 'Gestion Financière',
      subtitle: 'Transparence',
      description:
          'Gérez et suivez les finances de votre communauté de manière transparente et sécurisée.',
      imagePath: 'assets/images/unboarding_finance.svg',
    ),
  ];

  static const int totalPages = 3;
  static const Duration animationDuration = Duration(milliseconds: 600);
  static const Duration pageTransitionDuration = Duration(milliseconds: 400);
}
