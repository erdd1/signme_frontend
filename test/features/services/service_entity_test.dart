import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/core/permissions/app_permissions.dart';
import 'package:signme/features/auth/domain/entities/user_entity.dart';
import 'package:signme/features/services/domain/entities/service_entity.dart';
import 'package:signme/features/services/domain/gestion_actualites.dart';
import 'package:signme/features/services/domain/gestion_finance.dart';
import 'package:signme/features/services/domain/rapport_signatures.dart';
import 'package:signme/features/services/presentation/providers/services_provider.dart';

const _don = ServiceEntity(
  id: 'don',
  label: 'Faire un don',
  icon: Icons.volunteer_activism_rounded,
  section: 'Mes activités',
  route: '/services/don',
);

const _rapport = ServiceEntity(
  id: 'rapport',
  label: 'Télécharger un reçu',
  icon: Icons.receipt_long_rounded,
  section: 'Mes documents',
  route: '/recus',
);

UserEntity _user(String role) => UserEntity(
      id: 1,
      nom: 'Test',
      email: 't@eec.cm',
      role: role,
      actif: true,
      estDeService: false,
      churchId: 1,
    );

void main() {
  group('filterServices', () {
    test('sans texte, renvoie tous les services', () {
      expect(filterServices([_don, _rapport], ''), [_don, _rapport]);
      expect(filterServices([_don, _rapport], '   '), [_don, _rapport]);
    });

    test('cherche dans le libellé, sans casse ni accents', () {
      expect(filterServices([_don, _rapport], 'DON'), [_don]);
      expect(filterServices([_don, _rapport], 'recu'), [_rapport]);
      expect(filterServices([_don, _rapport], 'télécharger'), [_rapport]);
    });

    test('cherche aussi dans la rubrique', () {
      expect(filterServices([_don, _rapport], 'activites'), [_don]);
      expect(filterServices([_don, _rapport], 'documents'), [_rapport]);
    });

    test('aucun résultat pour un texte inconnu', () {
      expect(filterServices([_don, _rapport], 'xyz'), isEmpty);
    });
  });

  group('ServiceEntity.isAvailableFor', () {
    test('sans restriction, disponible pour tous', () {
      expect(_don.isAvailableFor(_user('paroissien')), isTrue);
    });

    test('avec restriction, suit la règle', () {
      final reserve = ServiceEntity(
        id: 'x',
        label: 'Réservé',
        icon: Icons.lock,
        section: 'Test',
        route: '/x',
        availableFor: (u) => u.role == 'pasteur',
      );

      expect(reserve.isAvailableFor(_user('pasteur')), isTrue);
      expect(reserve.isAvailableFor(_user('paroissien')), isFalse);
    });
  });

  group('catalogue', () {
    test('« Faire un don » est proposé à tous les rôles clients', () {
      final don = servicesCatalog.singleWhere((s) => s.id == 'don');

      for (final role in ['paroissien', 'ancien', 'secretaire', 'tresorier', 'pasteur']) {
        expect(don.isAvailableFor(_user(role)), isTrue, reason: role);
      }
    });

    test('les identifiants sont uniques', () {
      final ids = servicesCatalog.map((s) => s.id).toList();

      expect(ids.toSet().length, ids.length);
    });
  });

  group('navbar', () {
    test('Services remplace Historique pour tous, au même emplacement', () {
      for (final role in ['paroissien', 'ancien', 'secretaire', 'tresorier', 'pasteur']) {
        expect(
          AppPermissions.getNavTabs(_user(role)),
          [NavTab.home, NavTab.maCarte, NavTab.services, NavTab.profile],
          reason: role,
        );
      }
    });
  });

  group('Service « Gestion actualités » (regroupe les anciennes entrées du menu)', () {
    ServiceEntity tuile() => servicesCatalog.firstWhere((s) => s.id == 'gestion-actualites');

    test('la tuile est proposée au pasteur, à la secrétaire et au trésorier seulement', () {
      for (final role in ['pasteur', 'secretaire', 'tresorier']) {
        expect(tuile().isAvailableFor(_user(role)), isTrue, reason: role);
      }
      for (final role in ['paroissien', 'ancien']) {
        expect(tuile().isAvailableFor(_user(role)), isFalse, reason: role);
      }
    });

    test('chaque rôle retrouve exactement les droits de l\'ancien menu', () {
      List<String> ids(String role) => actionsGestionActualites(_user(role)).map((a) => a.id).toList();

      expect(ids('pasteur'), ['creer', 'gerer', 'contributions', 'publication-creer', 'publications']);
      expect(ids('secretaire'), ['creer', 'gerer', 'contributions', 'publication-creer', 'publications']);
      expect(ids('tresorier'), ['gerer', 'contributions']); // ni création d'événement ni publications
      expect(ids('paroissien'), isEmpty);
      expect(ids('ancien'), isEmpty);
    });

    test('les actions ouvrent les écrans existants, inchangés', () {
      final routes = actionsGestionActualites(_user('pasteur')).map((a) => a.route).toList();

      expect(routes, [
        '/evenements/create',
        '/evenements/gestion',
        '/contributions-evenement',
        '/publications/create',
        '/publications',
      ]);
    });

    test('les actions sont rangées par rubrique, événements puis publications', () {
      final sections = actionsGestionActualites(_user('pasteur')).map((a) => a.section).toList();

      expect(sections, ['Événements', 'Événements', 'Événements', 'Publications', 'Publications']);
      expect(actionsGestionActualites(_user('tresorier')).map((a) => a.section).toSet(), {'Événements'});
    });

    test('la tuile est rangée avec « Faire un don » dans Mes activités', () {
      expect(tuile().section, 'Mes activités');
      expect(tuile().label, 'Gestion actualités');
      expect(tuile().route, '/services/gestion-actualites');
    });
  });

  group('Service « Gestion finance » (regroupe les anciennes entrées du menu)', () {
    ServiceEntity tuile() => servicesCatalog.firstWhere((s) => s.id == 'gestion-finance');

    test('proposé au pasteur et au trésorier seulement', () {
      for (final role in ['pasteur', 'tresorier']) {
        expect(tuile().isAvailableFor(_user(role)), isTrue, reason: role);
      }
      for (final role in ['secretaire', 'paroissien', 'ancien']) {
        expect(tuile().isAvailableFor(_user(role)), isFalse, reason: role);
      }
    });

    test('ouvre les écrans existants, inchangés', () {
      final actions = actionsGestionFinance(_user('tresorier'));

      expect(actions.map((a) => a.route), ['/finances', '/sorties-financieres', '/retraits']);
      expect(actionsGestionFinance(_user('secretaire')), isEmpty);
    });

    test('est rangé à côté de « Gestion actualités »', () {
      final ids = servicesCatalog.map((s) => s.id).toList();

      expect(tuile().label, 'Gestion finance');
      expect(tuile().route, '/services/gestion-finance');
      expect(ids.indexOf('gestion-finance'), ids.indexOf('gestion-actualites') + 1);
    });
  });

  group('Service « Rapport signatures » (regroupe les anciennes entrées du menu)', () {
    ServiceEntity tuile() => servicesCatalog.firstWhere((s) => s.id == 'rapport-signatures');

    test('proposé au pasteur, aux anciens et à la secrétaire', () {
      for (final role in ['pasteur', 'ancien', 'secretaire']) {
        expect(tuile().isAvailableFor(_user(role)), isTrue, reason: role);
      }
      for (final role in ['paroissien', 'tresorier']) {
        expect(tuile().isAvailableFor(_user(role)), isFalse, reason: role);
      }
    });

    test('chaque rôle retrouve exactement les droits de l\'ancien menu', () {
      List<String> ids(String role) => actionsRapportSignatures(_user(role)).map((a) => a.id).toList();

      expect(ids('pasteur'), ['historique', 'rapport']);
      expect(ids('ancien'), ['historique']);
      expect(ids('secretaire'), ['rapport']);
      expect(ids('tresorier'), isEmpty);
    });

    test('ouvre les écrans existants et garde le badge des signatures non vues', () {
      final actions = actionsRapportSignatures(_user('pasteur'));

      expect(actions.map((a) => a.route), ['/historique-signatures', '/rapport-secretaire']);
      expect(actions.first.badgeType, 'historique_signatures');
      expect(actions.last.badgeType, isNull);
      expect(tuile().badgeType, 'historique_signatures');
    });

    test('la tuile reprend le compteur du badge', () {
      expect(tuile().withBadgeCount(4).badgeCount, 4);
      expect(tuile().withBadgeCount(4).route, tuile().route);
    });

    test('est rangé avec les autres services de gestion', () {
      final ids = servicesCatalog.map((s) => s.id).toList();

      expect(tuile().label, 'Rapport signatures');
      expect(tuile().route, '/services/rapport-signatures');
      expect(ids.indexOf('rapport-signatures'), ids.indexOf('gestion-finance') + 1);
    });
  });
}
