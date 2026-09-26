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
        annonces: 2,
        meditations: 4,
        evenements: 1,
        historique: 0,
        historiqueSignatures: 3,
      );
      const b = BadgeCountEntity(
        annonces: 2,
        meditations: 4,
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
      annonces: 2,
      meditations: 4,
      evenements: 1,
      historique: 0,
      historiqueSignatures: 3,
    );
    const b = BadgeCountEntity(
      annonces: 3,
      meditations: 4,
      evenements: 1,
      historique: 0,
      historiqueSignatures: 3,
    );

    expect(a, isNot(equals(b)));
  });

  test('copyWithZero ne remet à zéro que le type demandé', () {
    const original = BadgeCountEntity(
      annonces: 2,
      meditations: 4,
      evenements: 1,
      historique: 5,
      historiqueSignatures: 3,
    );

    final result = original.copyWithZero('meditations');

    expect(result.meditations, 0);
    expect(result.annonces, 2);
    expect(result.evenements, 1);
    expect(result.historique, 5);
    expect(result.historiqueSignatures, 3);
  });
}
