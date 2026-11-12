import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/chants/domain/chant_navigateur.dart';

void main() {
  group('Moteur de recherche', () {
    test('Google et YouTube ouvrent leurs vraies pages de résultats', () {
      expect(MoteurRecherche.google.urlPour('jesus te confie').toString(),
          'https://www.google.com/search?q=jesus+te+confie+chant');
      expect(MoteurRecherche.youtube.urlPour('jesus te confie').toString(),
          'https://m.youtube.com/results?search_query=jesus+te+confie+chant');
    });

    test('le mot « chant » n\'est pas ajouté deux fois', () {
      expect(MoteurRecherche.google.urlPour('chant de louange').queryParameters['q'], 'chant de louange');
    });

    test('les caractères spéciaux de la saisie sont encodés, jamais interprétés', () {
      final url = MoteurRecherche.google.urlPour('a&b=c#d');
      expect(url.queryParameters['q'], 'a&b=c#d chant');
      expect(url.host, 'www.google.com');
    });
  });

  group('Vidéos YouTube reconnues dans l\'adresse affichée', () {
    test('toutes les formes d\'un lien de vidéo donnent le même identifiant', () {
      for (final url in [
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'https://m.youtube.com/watch?v=dQw4w9WgXcQ&list=PLx&t=5s',
        'https://youtu.be/dQw4w9WgXcQ?si=abc',
        'https://music.youtube.com/watch?v=dQw4w9WgXcQ',
        'https://www.youtube.com/shorts/dQw4w9WgXcQ',
        'https://www.youtube.com/embed/dQw4w9WgXcQ',
      ]) {
        expect(ChantNavigateur.idVideoYoutube(Uri.parse(url)), 'dQw4w9WgXcQ', reason: url);
      }
    });

    test('une page de résultats, la page d\'accueil ou un autre site ne sont pas une vidéo', () {
      for (final url in [
        'https://m.youtube.com/results?search_query=louange',
        'https://www.youtube.com/',
        'https://www.youtube.com/@chorale',
        'https://www.google.com/watch?v=dQw4w9WgXcQ',
        'https://exemple.org/watch?v=dQw4w9WgXcQ',
        'https://www.youtube.com/watch?v=<script>',
        'https://www.youtube.com/watch',
      ]) {
        expect(ChantNavigateur.idVideoYoutube(Uri.parse(url)), isNull, reason: url);
      }
    });
  });

  group('Pages qu\'on peut garder', () {
    test('une page de résultats de moteur n\'est jamais un chant', () {
      for (final url in [
        'https://www.google.com/search?q=louange',
        'https://www.google.cm/search?q=louange',
        'https://www.google.com/',
        'https://m.youtube.com/results?search_query=louange',
        'https://www.youtube.com/',
      ]) {
        expect(ChantNavigateur.estPageDeRecherche(Uri.parse(url)), isTrue, reason: url);
        expect(ChantNavigateur.estEnregistrable(Uri.parse(url)), isFalse, reason: url);
      }
    });

    test('une page de site ordinaire se garde', () {
      expect(ChantNavigateur.estEnregistrable(Uri.parse('https://exemple.org/cantique/12')), isTrue);
      expect(ChantNavigateur.estEnregistrable(Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ')), isTrue);
    });

    test('rien d\'autre que http(s) n\'est gardé ni suivi', () {
      for (final url in ['javascript:alert(1)', 'file:///etc/passwd', 'intent://x#Intent;end', 'market://details?id=x', 'vnd.youtube://x']) {
        expect(ChantNavigateur.estEnregistrable(Uri.parse(url)), isFalse, reason: url);
        expect(ChantNavigateur.schemeAutorise(url), isFalse, reason: url);
      }
      expect(ChantNavigateur.schemeAutorise('https://www.google.com'), isTrue);
      expect(ChantNavigateur.schemeAutorise('http://192.168.1.1/x'), isTrue);
      expect(ChantNavigateur.schemeAutorise('about:blank'), isTrue);
    });
  });

  group('Titre propre', () {
    test('retire le suffixe YouTube et les espaces superflus', () {
      expect(ChantNavigateur.titrePropre('  Jésus te confie   -   YouTube ', repli: 'x'), 'Jésus te confie');
      expect(ChantNavigateur.titrePropre('Grand est ton amour | YouTube', repli: 'x'), 'Grand est ton amour');
    });

    test('un titre vide ou « YouTube » seul prend le repli', () {
      expect(ChantNavigateur.titrePropre(null, repli: 'Vidéo YouTube'), 'Vidéo YouTube');
      expect(ChantNavigateur.titrePropre('YouTube', repli: 'Vidéo YouTube'), 'Vidéo YouTube');
      expect(ChantNavigateur.titrePropre('   ', repli: 'exemple.org'), 'exemple.org');
    });

    test('un titre démesuré est tronqué', () {
      expect(ChantNavigateur.titrePropre('a' * 500, repli: 'x').length, 200);
    });

    test('la vignette est l\'adresse publique de la vidéo (aucun appel d\'API)', () {
      expect(ChantNavigateur.vignette('dQw4w9WgXcQ'), 'https://i.ytimg.com/vi/dQw4w9WgXcQ/mqdefault.jpg');
    });
  });
}
