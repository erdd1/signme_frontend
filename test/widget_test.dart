import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signme/main.dart';

void main() {
  testWidgets('App démarre sans erreur (smoke test)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SignMeApp()),
    );
    // L'app doit démarrer sur le splash screen
    await tester.pump(const Duration(milliseconds: 300));
    // Vérifie qu'aucune exception n'est levée
    expect(tester.takeException(), isNull);
  });
}
