import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/badge/domain/entities/badge_count_entity.dart';

void main() {
  test(
    'deux BadgeCountEntity avec les mêmes compteurs sont égales — sans '
    'quoi chaque polling (60s, toute la session) déclenchait un rebuild '
    'complet de MainShell (dont le flou BackdropFilter de la navbar) même '
    "quand rien n'avait changé",
    () {
      const a = BadgeCountEntity(
        publications: 2,
        evenements: 1,
        historique: 0,
        historiqueSignatures: 3,
      );
      const b = BadgeCountEntity(
        publications: 2,
        evenements: 1,
        historique: 0,
        historiqueSignatures: 3,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    },
  );

  test('des compteurs différents ne sont pas égaux', () {
    const a = BadgeCountEntity(
      publications: 2,
      evenements: 1,
      historique: 0,
      historiqueSignatures: 3,
    );
    const b = BadgeCountEntity(
      publications: 3,
      evenements: 1,
      historique: 0,
      historiqueSignatures: 3,
    );

    expect(a, isNot(equals(b)));
  });
}
