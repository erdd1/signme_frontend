import 'package:flutter_test/flutter_test.dart';
import 'package:signme/core/router/app_router.dart';

void main() {
  group('Habillage des routes dans le shell', () {
    test('les services de gestion, le don et le rapport signatures sont en plein écran', () {
      for (final route in [
        AppRoutes.servicesDon,
        AppRoutes.servicesGestionActualites,
        AppRoutes.servicesGestionFinance,
        AppRoutes.servicesRapportSignatures,
      ]) {
        expect(AppRoutes.isFullScreenService(route), isTrue, reason: route);
        // Plein écran = en-tête propre : jamais deux barres empilées.
        expect(AppRoutes.hasOwnHeader(route), isTrue, reason: route);
      }
    });

    test('les onglets et les modules du menu gardent l\'en-tête du shell', () {
      for (final route in [
        AppRoutes.home,
        AppRoutes.finances,
        AppRoutes.services,
        AppRoutes.maCarte,
        AppRoutes.profile,
        AppRoutes.users,
        AppRoutes.anciensDesignations,
        AppRoutes.mesDepenses,
        AppRoutes.parametres,
        AppRoutes.celebrations,
        AppRoutes.historiquePersonnel,
      ]) {
        expect(AppRoutes.isFullScreenService(route), isFalse, reason: route);
        expect(AppRoutes.hasOwnHeader(route), isFalse, reason: route);
      }
    });

    test('les modules ouverts depuis un service portent leur propre en-tête', () {
      for (final route in [
        AppRoutes.evenementCreate,
        AppRoutes.gestionEvenements,
        AppRoutes.contributionsEvenement,
        AppRoutes.publications,
        AppRoutes.publicationCreate,
        AppRoutes.sortiesFinancieres,
        AppRoutes.retraits,
        AppRoutes.historiqueSignatures,
        AppRoutes.rapportSecretaire,
      ]) {
        expect(AppRoutes.hasOwnHeader(route), isTrue, reason: route);
        // En-tête propre, mais la navbar reste (seuls les services sont plein écran).
        expect(AppRoutes.isFullScreenService(route), isFalse, reason: route);
      }
    });

    test('les écrans de détail et de formulaire portent leur propre en-tête', () {
      for (final route in [
        AppRoutes.changePassword,
        AppRoutes.userCreate,
        AppRoutes.userStats,
        AppRoutes.userDetailPath(7),
        AppRoutes.userEditPath(7),
        AppRoutes.publicationCreate,
        AppRoutes.publicationDetailPath(3),
        AppRoutes.publicationEditPath(3),
        AppRoutes.gestionEvenements,
        AppRoutes.evenementDetailPath('abc'),
        AppRoutes.contributionFormPath('abc'),
      ]) {
        expect(AppRoutes.hasOwnHeader(route), isTrue, reason: route);
        expect(AppRoutes.isFullScreenService(route), isFalse, reason: route);
      }
    });
  });
}
