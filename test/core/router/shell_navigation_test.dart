import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:signme/core/router/app_router.dart';

/// Garde-fou de l'erreur « !keyReservation.contains(key) » : un écran de
/// service ouvert hors du shell, qui ouvre à son tour un écran du shell,
/// provoquait une assertion du Navigator (clé de page dupliquée).
///
/// Ces tests reproduisent la topologie réelle du routeur (un ShellRoute et des
/// écrans de service) pour vérifier que la bonne déclaration — dans le shell —
/// navigue sans erreur, et que la mauvaise — hors shell — provoque bien celle-ci.
void main() {
  GoRouter buildRouter({required bool servicesInShell}) {
    GoRoute page(String path, Widget Function(BuildContext) builder) => GoRoute(
          path: path,
          pageBuilder: (context, state) => MaterialPage<void>(key: state.pageKey, child: Builder(builder: builder)),
        );

    final service = page('/service', (context) {
      return TextButton(
        onPressed: () => context.push(AppRoutes.retraits),
        child: const Text('Ouvrir retraits'),
      );
    });
    final retraits = page(AppRoutes.retraits, (_) => const Text('Écran retraits'));

    return GoRouter(
      initialLocation: AppRoutes.services,
      routes: [
        ShellRoute(
          builder: (context, state, child) => Scaffold(body: child),
          routes: [
            page(AppRoutes.services, (context) {
              return TextButton(
                onPressed: () => context.push('/service'),
                child: const Text('Ouvrir le service'),
              );
            }),
            if (servicesInShell) service,
            retraits,
          ],
        ),
        if (!servicesInShell) service,
      ],
    );
  }

  testWidgets('un service déclaré dans le shell ouvre un écran du shell sans erreur', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: buildRouter(servicesInShell: true)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ouvrir le service'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ouvrir retraits'));
    await tester.pumpAndSettle();

    expect(find.text('Écran retraits'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('le retour depuis l\'écran du shell revient au service', (tester) async {
    final router = buildRouter(servicesInShell: true);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ouvrir le service'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ouvrir retraits'));
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('Ouvrir retraits'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('le même service déclaré HORS du shell reproduit l\'erreur d\'origine', (tester) async {
    // Le Navigator signale l'assertion à chaque reconstruction : on collecte
    // toutes les erreurs plutôt que d'en reprendre une seule.
    final errors = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previous);

    await tester.pumpWidget(MaterialApp.router(routerConfig: buildRouter(servicesInShell: false)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ouvrir le service'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ouvrir retraits'));
    await tester.pumpAndSettle();

    expect(errors.any((e) => e.exceptionAsString().contains('keyReservation')), isTrue);
  });
}
