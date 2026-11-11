import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/auth/data/models/user_model.dart';
import 'package:signme/features/auth/domain/entities/user_lookup_refs.dart';
import 'package:signme/features/groupes/domain/entities/groupe_entities.dart';
import 'package:signme/features/users/presentation/widgets/groupes_multi_select.dart';

/// Monte [GroupesMultiSelect] avec un état local, et expose le dernier état
/// émis par `onChanged`.
class _Harness extends StatefulWidget {
  const _Harness({required this.initial, required this.onEmit});

  final Map<int, Set<String>> initial;
  final void Function(Map<int, Set<String>>) onEmit;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late Map<int, Set<String>> selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: GroupesMultiSelect(
            groupes: const [GroupeRef(id: 1, nom: 'Chorale'), GroupeRef(id: 2, nom: 'Cojeunesse')],
            selected: selected,
            onChanged: (value) {
              setState(() => selected = value);
              widget.onEmit(value);
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  group('GroupeEntity', () {
    GroupeEntity groupe(List<String> postes) =>
        GroupeEntity.fromJson({'uuid': 'u1', 'nom': 'Cojeunesse', 'postes': postes});

    test('le libellé du poste couvre membre, président, trésorier et le cumul', () {
      expect(groupe([]).posteLabel, 'Membre');
      expect(groupe(['president']).posteLabel, 'Président');
      expect(groupe(['tresorier']).posteLabel, 'Trésorier');
      expect(groupe(['president', 'tresorier']).posteLabel, 'Président & trésorier');
    });

    test('seuls le président et le trésorier gèrent la caisse', () {
      expect(groupe([]).estResponsable, isFalse);
      expect(groupe(['president']).estResponsable, isTrue);
      expect(groupe(['tresorier']).estResponsable, isTrue);
      expect(groupe(['tresorier']).estPresident, isFalse);
    });

    test('lit la caisse et les responsables', () {
      final g = GroupeEntity.fromJson({
        'uuid': 'u1',
        'nom': 'Cojeunesse',
        'postes': ['president'],
        'caisse': {'enLigne': 10000, 'retraits': 4000, 'soldeEnLigne': 6000, 'cash': 4000, 'total': 10000},
        'responsables': {'president': 'Paul', 'tresorier': null},
      });

      expect(g.caisse!.soldeEnLigne, 6000);
      expect(g.caisse!.total, 10000);
      expect(g.president, 'Paul');
      expect(g.tresorier, isNull);
    });
  });

  group('CommuniqueEntity', () {
    CommuniqueEntity communique({int? objectif, int collecte = 0}) => CommuniqueEntity.fromJson({
          'uuid': 'c1',
          'titre': 'Dons',
          'message': 'msg',
          'objectifMontant': objectif,
          'montantCollecte': collecte,
          'nombreContributions': 2,
        });

    test('sans objectif, pas de barre de progression', () {
      expect(communique(collecte: 5000).progression, isNull);
    });

    test('la progression est plafonnée à 100 %', () {
      expect(communique(objectif: 10000, collecte: 2500).progression, 0.25);
      expect(communique(objectif: 10000, collecte: 30000).progression, 1.0);
    });
  });

  group('MouvementEntity', () {
    test('distingue entrée/sortie et entrée cash annulée', () {
      final m = MouvementEntity.fromJson({
        'id': 'cash:1',
        'type': 'cash',
        'sens': 'entree',
        'montant': 4000,
        'annule': true,
        'date': '2026-11-12T10:00:00Z',
      });

      expect(m.estEntree, isTrue);
      expect(m.estCash, isTrue);
      expect(m.annule, isTrue);
      expect(MouvementEntity.fromJson({'type': 'retrait', 'sens': 'sortie'}).estEntree, isFalse);
    });
  });

  group('UserModel', () {
    test('lit le poste et l\'uuid de chaque groupe, sans groupe principal', () {
      final user = UserModel.fromJson({
        'id': 1,
        'nom': 'Paul',
        'email': 'p@eec.cm',
        'role': 'paroissien',
        'groupes': [
          {'id': 3, 'uuid': 'g-3', 'nom': 'Cojeunesse', 'postes': ['president', 'tresorier']},
          {'id': 4, 'uuid': 'g-4', 'nom': 'Conseillers', 'postes': []},
        ],
      });

      expect(user.groupes.first.estPresident, isTrue);
      expect(user.groupes.first.estTresorier, isTrue);
      expect(user.groupes.first.uuid, 'g-3');
      expect(user.groupes.last.postes, isEmpty);
      expect(user.toJson()['groupes'], isA<List>());
      expect(user.toJson().containsKey('groupePrincipal'), isFalse);
    });

    test('un groupe renvoyé par une ancienne API (sans poste) reste lisible', () {
      final g = GroupeRef.fromJson({'id': 1, 'nom': 'Chorale'});
      expect(g.postes, isEmpty);
      expect(g.uuid, isNull);
    });
  });

  group('GroupesMultiSelect — poste dans chaque groupe', () {
    testWidgets('cocher un groupe le rend simple membre, avec le choix du poste', (tester) async {
      await tester.pumpWidget(_Harness(initial: const {}, onEmit: (_) {}));
      expect(find.text('Poste dans le groupe'), findsNothing);

      await tester.tap(find.text('Cojeunesse'));
      await tester.pump();

      expect(find.text('Poste dans le groupe'), findsOneWidget);
      expect(find.text('Membre'), findsOneWidget);
      expect(find.text('Président'), findsOneWidget);
      expect(find.text('Trésorier'), findsOneWidget);
    });

    testWidgets('président et trésorier se cumulent, « Membre » les remet à zéro', (tester) async {
      Map<int, Set<String>>? dernier;
      await tester.pumpWidget(_Harness(initial: {2: <String>{}}, onEmit: (v) => dernier = v));

      await tester.tap(find.text('Président'));
      await tester.pump();
      await tester.tap(find.text('Trésorier'));
      await tester.pump();
      expect(dernier![2], {GroupePoste.president, GroupePoste.tresorier});

      await tester.tap(find.text('Membre'));
      await tester.pump();
      expect(dernier![2], isEmpty);
    });

    testWidgets('décocher un groupe retire aussi son poste', (tester) async {
      Map<int, Set<String>>? dernier;
      await tester.pumpWidget(_Harness(
        initial: {1: {GroupePoste.president}},
        onEmit: (v) => dernier = v,
      ));

      // Le nom du groupe apparaît dans la puce ET dans la carte de poste.
      await tester.tap(find.text('Chorale').first);
      await tester.pump();

      expect(dernier, isNot(contains(1)));
      expect(find.text('Poste dans le groupe'), findsNothing);
    });
  });
}
