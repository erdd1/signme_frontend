import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:signme/core/router/app_router.dart';

/// Vérifie le VRAI routeur de l'app : les écrans de service plein écran doivent
/// être déclarés dans le ShellRoute (voir AppRoutes.fullScreenServices) — hors
/// shell, ouvrir un de leurs écrans plante avec « !keyReservation.contains(key) ».
void main() {
  test('les services plein écran sont déclarés dans le shell, jamais à la racine', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    final rootPaths = <String>{};
    final shellPaths = <String>{};

    void collect(List<RouteBase> routes, Set<String> into) {
      for (final route in routes) {
        if (route is GoRoute) {
          into.add(route.path);
          collect(route.routes, into);
        } else if (route is ShellRouteBase) {
          collect(route.routes, shellPaths);
        }
      }
    }

    collect(router.configuration.routes, rootPaths);

    // Garde-fou du test lui-même : la collecte distingue bien shell et racine.
    expect(shellPaths, contains(AppRoutes.finances));
    expect(shellPaths, contains(AppRoutes.retraits));
    expect(rootPaths, contains(AppRoutes.assistant));
    expect(rootPaths, contains(AppRoutes.servicesTransactions));

    for (final path in AppRoutes.fullScreenServices) {
      expect(shellPaths, contains(path), reason: '$path doit être dans le shell');
      expect(rootPaths, isNot(contains(path)), reason: '$path ne doit pas être à la racine');
    }
  });
}
