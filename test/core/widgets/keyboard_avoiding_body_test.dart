import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/core/widgets/keyboard_avoiding_body.dart';
import 'package:signme/core/widgets/keyboard_dismiss_scope.dart';

/// Écran comme dans la coque de l'application : le Scaffold ne se redimensionne
/// pas (resizeToAvoidBottomInset: false), seul le contenu s'adapte au clavier.
Widget _shell({required bool avoiding}) {
  const content = Column(
    children: [
      Expanded(child: SingleChildScrollView(child: SizedBox(height: 400))),
      TextField(key: Key('montant'), keyboardType: TextInputType.number),
    ],
  );

  return MaterialApp(
    builder: (context, child) => KeyboardDismissScope(child: child!),
    home: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          avoiding ? const KeyboardAvoidingBody(child: content) : content,
          const Positioned(bottom: 0, left: 0, right: 0, child: SizedBox(key: Key('navbar'), height: 60)),
        ],
      ),
    ),
  );
}

void _openKeyboard(WidgetTester tester) {
  tester.view.viewInsets = const FakeViewPadding(bottom: 600); // 200 px logiques
  addTearDown(tester.view.resetViewInsets);
}

void main() {
  testWidgets('le champ reste au-dessus du clavier ET de la barre « Terminé » (iOS)', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      _openKeyboard(tester);
      await tester.pumpWidget(_shell(avoiding: true));
      await tester.tap(find.byKey(const Key('montant')));
      await tester.pump();

      final keyboard = 600 / tester.view.devicePixelRatio;
      final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final fieldBottom = tester.getBottomLeft(find.byKey(const Key('montant'))).dy;

      expect(find.text('Terminé'), findsOneWidget);
      expect(fieldBottom, lessThanOrEqualTo(screenHeight - keyboard - kKeyboardDoneBarHeight));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('sans ce widget, le champ passe sous la barre (cas corrigé)', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      _openKeyboard(tester);
      await tester.pumpWidget(_shell(avoiding: false));
      await tester.tap(find.byKey(const Key('montant')));
      await tester.pump();

      final keyboard = 600 / tester.view.devicePixelRatio;
      final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final fieldBottom = tester.getBottomLeft(find.byKey(const Key('montant'))).dy;

      expect(fieldBottom, greaterThan(screenHeight - keyboard - kKeyboardDoneBarHeight));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('les éléments hors du contenu (navbar) gardent leur position', (tester) async {
    await tester.pumpWidget(_shell(avoiding: true));
    final before = tester.getTopLeft(find.byKey(const Key('navbar')));

    _openKeyboard(tester);
    await tester.pump();

    expect(tester.getTopLeft(find.byKey(const Key('navbar'))), before);
  });

  testWidgets('les descendants ne voient plus la hauteur du clavier (pas de double compensation)', (tester) async {
    double? seen;
    _openKeyboard(tester);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: KeyboardAvoidingBody(
          child: Builder(builder: (context) {
            seen = MediaQuery.of(context).viewInsets.bottom;
            return const SizedBox.shrink();
          }),
        ),
      ),
    ));

    expect(seen, 0);
  });
}
