import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/main/presentation/screens/main_shell.dart';

void main() {
  group('floatingNavBottomOffset', () {
    test('iPhone à barre d\'accueil : la navbar se pose juste au-dessus (34 -> 20)', () {
      expect(floatingNavBottomOffset(safeBottom: 34, platform: TargetPlatform.iOS), 20);
    });

    test('iPhone à bouton (aucune zone de sécurité) : marge minimale', () {
      expect(floatingNavBottomOffset(safeBottom: 0, platform: TargetPlatform.iOS), 12);
    });

    test('iOS : jamais moins que la marge minimale', () {
      expect(floatingNavBottomOffset(safeBottom: 20, platform: TargetPlatform.iOS), 12);
    });

    test('Android : inchangé, marge + zone de sécurité', () {
      expect(floatingNavBottomOffset(safeBottom: 0, platform: TargetPlatform.android), 12);
      expect(floatingNavBottomOffset(safeBottom: 48, platform: TargetPlatform.android), 60);
    });
  });
}
