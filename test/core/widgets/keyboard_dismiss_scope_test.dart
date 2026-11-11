import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/core/widgets/keyboard_dismiss_scope.dart';

/// Écran de test : un champ numérique, un champ téléphone, un champ texte et
/// une zone vide. L'enrobage est placé dans le `builder` de MaterialApp,
/// exactement comme dans l'application (au-dessus du Scaffold, donc là où la
/// hauteur du clavier est encore connue).
Widget _app() => MaterialApp(
      builder: (context, child) => KeyboardDismissScope(child: child!),
      home: const Scaffold(
        body: Column(
          children: [
            TextField(key: Key('montant'), keyboardType: TextInputType.number),
            TextField(key: Key('telephone'), keyboardType: TextInputType.phone),
            TextField(key: Key('nom'), keyboardType: TextInputType.text),
            Expanded(child: SizedBox.expand(key: Key('vide'))),
          ],
        ),
      ),
    );

/// Simule un clavier ouvert (hauteur 300) sur la vue de test.
void _openKeyboard(WidgetTester tester) {
  tester.view.viewInsets = const FakeViewPadding(bottom: 300);
  addTearDown(tester.view.resetViewInsets);
}

/// Exécute [body] avec la plateforme simulée, puis la rétablit AVANT la fin du
/// test (Flutter vérifie qu'aucune variable de débogage n'est laissée modifiée).
Future<void> _on(TargetPlatform platform, Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = platform;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

void main() {
  testWidgets('iOS : une barre « Terminé » apparaît sur un clavier numérique et le referme', (tester) async {
    await _on(TargetPlatform.iOS, () async {
      _openKeyboard(tester);
      await tester.pumpWidget(_app());

      await tester.tap(find.byKey(const Key('montant')));
      await tester.pump();

      expect(find.text('Terminé'), findsOneWidget);
      expect(FocusManager.instance.primaryFocus, isNotNull);

      await tester.tap(find.text('Terminé'));
      await tester.pump();

      expect(find.text('Terminé'), findsNothing);
      expect(FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<EditableText>(), isNull);
    });
  });

  testWidgets('iOS : la barre apparaît aussi pour un clavier téléphone', (tester) async {
    await _on(TargetPlatform.iOS, () async {
      _openKeyboard(tester);
      await tester.pumpWidget(_app());

      await tester.tap(find.byKey(const Key('telephone')));
      await tester.pump();

      expect(find.text('Terminé'), findsOneWidget);
    });
  });

  testWidgets('iOS : pas de barre pour un clavier texte (il a déjà sa touche de validation)', (tester) async {
    await _on(TargetPlatform.iOS, () async {
      _openKeyboard(tester);
      await tester.pumpWidget(_app());

      await tester.tap(find.byKey(const Key('nom')));
      await tester.pump();

      expect(find.text('Terminé'), findsNothing);
    });
  });

  testWidgets('iOS : pas de barre quand le clavier est fermé', (tester) async {
    await _on(TargetPlatform.iOS, () async {
      await tester.pumpWidget(_app());

      await tester.tap(find.byKey(const Key('montant')));
      await tester.pump();

      expect(find.text('Terminé'), findsNothing);
    });
  });

  testWidgets('Android : pas de barre « Terminé »', (tester) async {
    await _on(TargetPlatform.android, () async {
      _openKeyboard(tester);
      await tester.pumpWidget(_app());

      await tester.tap(find.byKey(const Key('montant')));
      await tester.pump();

      expect(find.text('Terminé'), findsNothing);
    });
  });

  testWidgets('toucher en dehors du champ referme le clavier, sur toutes les plateformes', (tester) async {
    await _on(TargetPlatform.android, () async {
      _openKeyboard(tester);
      await tester.pumpWidget(_app());

      await tester.tap(find.byKey(const Key('nom')));
      await tester.pump();
      expect(FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<EditableText>(), isNotNull);

      await tester.tap(find.byKey(const Key('vide')));
      await tester.pump();

      expect(FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<EditableText>(), isNull);
    });
  });

  testWidgets('toucher un autre champ garde le clavier ouvert (focus transféré)', (tester) async {
    await _on(TargetPlatform.android, () async {
      _openKeyboard(tester);
      await tester.pumpWidget(_app());

      await tester.tap(find.byKey(const Key('nom')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('montant')));
      await tester.pump();

      final focused = FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<EditableText>();
      expect(focused?.keyboardType, TextInputType.number);
    });
  });
}
