import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/chant_navigateur.dart';
import '../../domain/entities/chant_hub_entities.dart';
import '../providers/chants_provider.dart';
import '../widgets/chant_card.dart';
import 'chants_navigateur_screen.dart';
import '../widgets/chant_reference_tile.dart';
import '../widgets/chant_video_card.dart';

/// Mention affichée tant que le serveur n'en a pas fourni (modifiable côté serveur).
const String kChantsMentionParDefaut =
    'SignMe n\'a aucun droit sur les chants proposés : ils appartiennent à leurs auteurs et aux sources indiquées.';

/// Hub de chants : recherche unique (chants déjà référencés, vidéos, paroles),
/// et — avant toute saisie — mes favoris, mes chants récents et les chants du moment.
class ChantsScreen extends ConsumerStatefulWidget {
  const ChantsScreen({super.key});

  @override
  ConsumerState<ChantsScreen> createState() => _ChantsScreenState();
}

class _ChantsScreenState extends ConsumerState<ChantsScreen> {
  static const List<String> _suggestions = [
    'Grâce infinie',
    'Alléluia',
    'À toi la gloire',
    'Dieu tout-puissant',
    'Louange',
  ];

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) => ref.read(chantsSearchProvider.notifier).onQueryChanged(value);

  void _applySuggestion(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _search(value);
  }

  void _clear() {
    _controller.clear();
    _search('');
  }

  /// Ouvre le navigateur intégré sur la recherche du chrétien (vraies pages Google / YouTube).
  Future<void> _navigateur(String requete, MoteurRecherche moteur) async {
    await context.pushNamed('chants-navigateur', extra: ChantsNavigateurArgs(requete: requete, moteur: moteur));
    if (mounted) rafraichirAccueilChants(ref);
  }

  /// Ouvre la fiche d'un chant ; au retour, mes listes sont à jour (historique, favoris).
  Future<void> _ouvrir(ChantAOuvrir cible) async {
    await context.pushNamed('chant-detail', extra: cible);
    if (mounted) rafraichirAccueilChants(ref);
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(chantsSearchProvider);
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    // La navbar flottante se masque avec le clavier : le contenu doit alors
    // se dégager au-dessus du clavier plutôt que de la navbar.
    final bottomPadding = keyboardInset > 0
        ? keyboardInset + SignmeSpacing.lg
        : SignmeSpacing.navbarClearance;

    return Scaffold(
      backgroundColor: SignmeColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SignmeSpacing.lg,
              SignmeSpacing.sm,
              SignmeSpacing.lg,
              SignmeSpacing.md,
            ),
            child: TextField(
              controller: _controller,
              onChanged: (v) {
                setState(() {}); // met à jour le bouton d'effacement
                _search(v);
              },
              textInputAction: TextInputAction.search,
              style: SignmeTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Titre, paroles ou chant…',
                prefixIcon: const Icon(Icons.search_rounded, color: SignmeColors.mediumGray),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, color: SignmeColors.mediumGray),
                        tooltip: 'Effacer',
                        onPressed: _clear,
                      ),
                filled: true,
                fillColor: SignmeColors.accentSky.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: search.isIdle
                ? _Accueil(
                    suggestions: _suggestions,
                    onSuggestion: _applySuggestion,
                    onOuvrir: _ouvrir,
                    bottomPadding: bottomPadding,
                  )
                : search.result.when(
                    loading: () => ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                      children: const [SignmeSkeletonList(itemCount: 5, itemHeight: 104)],
                    ),
                    error: (e, _) => SignmeErrorState(
                      title: 'Recherche impossible',
                      message: messageFromError(e),
                      icon: e is NetworkException ? Icons.wifi_off_rounded : Icons.error_outline,
                      onRetry: ref.read(chantsSearchProvider.notifier).retry,
                    ),
                    data: (resultat) => resultat.estVide
                        ? SignmeEmptyState(
                            icon: Icons.travel_explore_rounded,
                            title: 'Pas encore dans le répertoire',
                            message: resultat.partiel
                                ? 'Certaines sources n\'ont pas répondu. Cherchez-le directement sur Google ou YouTube, sans quitter SignMe.'
                                : 'Cherchez ce chant sur Google ou YouTube, sans quitter SignMe : celui que vous regardez sera retenu dans vos chants.',
                            action: _Navigateurs(requete: search.query, onOuvrir: _navigateur),
                          )
                        : _Resultats(
                            resultat: resultat,
                            requete: search.query,
                            onNavigateur: _navigateur,
                            onOuvrir: _ouvrir,
                            bottomPadding: bottomPadding,
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Résultats d'une recherche : mes chants déjà référencés, vidéos, paroles.
class _Resultats extends StatelessWidget {
  const _Resultats({
    required this.resultat,
    required this.requete,
    required this.onNavigateur,
    required this.onOuvrir,
    required this.bottomPadding,
  });

  final ChantsSearchResult resultat;
  final String requete;
  final void Function(String requete, MoteurRecherche moteur) onNavigateur;
  final ValueChanged<ChantAOuvrir> onOuvrir;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.sm, SignmeSpacing.lg, bottomPadding),
      children: [
        _Navigateurs(requete: requete, onOuvrir: onNavigateur),
        const SizedBox(height: SignmeSpacing.md),
        if (resultat.partiel)
          const _Bandeau(
            icon: Icons.info_outline_rounded,
            texte: 'Certaines sources n\'ont pas répondu : voici déjà ce qui a été trouvé.',
          ),
        if (resultat.references.isNotEmpty) ...[
          const _TitreSection('MES CHANTS'),
          for (final c in resultat.references)
            Padding(
              padding: const EdgeInsets.only(bottom: SignmeSpacing.md),
              child: ChantReferenceTile(chant: c, onTap: () => onOuvrir(OuvrirReference(c.uuid, titre: c.titre))),
            ),
        ],
        if (resultat.videos.isNotEmpty) ...[
          const _TitreSection('VIDÉOS'),
          for (final v in resultat.videos)
            Padding(
              padding: const EdgeInsets.only(bottom: SignmeSpacing.md),
              child: ChantVideoCard(video: v, onTap: () => onOuvrir(OuvrirVideo(v))),
            ),
        ],
        if (resultat.paroles.isNotEmpty) ...[
          const _TitreSection('PAROLES'),
          for (final p in resultat.paroles)
            Padding(
              padding: const EdgeInsets.only(bottom: SignmeSpacing.md),
              child: ChantCard(chant: p, onTap: () => onOuvrir(OuvrirParoles(p))),
            ),
        ],
        const SizedBox(height: SignmeSpacing.sm),
        _Mention(texte: resultat.mention),
      ],
    );
  }
}

/// Chercher le même chant sur Google ou YouTube, dans le navigateur intégré à SignMe.
class _Navigateurs extends StatelessWidget {
  const _Navigateurs({required this.requete, required this.onOuvrir});

  final String requete;
  final void Function(String requete, MoteurRecherche moteur) onOuvrir;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TitreSection('CHERCHER AUSSI SUR'),
        Row(
          children: [
            for (final m in MoteurRecherche.values) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onOuvrir(requete, m),
                  icon: Icon(m == MoteurRecherche.google ? Icons.search_rounded : Icons.play_circle_outline_rounded, size: 20),
                  label: Text(m.libelle),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SignmeColors.primaryLight,
                    side: const BorderSide(color: SignmeColors.primaryLight),
                    padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd)),
                  ),
                ),
              ),
              if (m == MoteurRecherche.google) const SizedBox(width: SignmeSpacing.md),
            ],
          ],
        ),
      ],
    );
  }
}

/// Avant toute saisie : mes favoris, mes chants récents, les chants du moment.
/// Un nouveau chrétien (rien encore) voit l'invitation à chercher.
class _Accueil extends ConsumerWidget {
  const _Accueil({
    required this.suggestions,
    required this.onSuggestion,
    required this.onOuvrir,
    required this.bottomPadding,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSuggestion;
  final ValueChanged<ChantAOuvrir> onOuvrir;
  final double bottomPadding;

  static const int _apercu = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoris = ref.watch(chantsFavorisProvider);
    final recents = ref.watch(chantsHistoriqueProvider);
    final tendances = ref.watch(chantsTendancesProvider);
    final etats = [favoris, recents, tendances];

    // Le hub ne répond pas du tout : message clair, le reste de SignMe n'est pas touché.
    if (etats.every((e) => e.hasError)) {
      final erreur = favoris.error;
      return SignmeErrorState(
        title: 'Répertoire indisponible',
        message: messageFromError(erreur ?? ''),
        icon: erreur is NetworkException ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
        onRetry: () => rafraichirAccueilChants(ref),
      );
    }

    final premierChargement = etats.every((e) => e.isLoading && !e.hasValue);
    final rien = etats.every((e) => (e.valueOrNull ?? const []).isEmpty);

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () async => rafraichirAccueilChants(ref),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.sm, SignmeSpacing.lg, bottomPadding),
        children: [
          if (premierChargement)
            const SignmeSkeletonList(itemCount: 4, itemHeight: 84)
          else if (rien)
            _Invitation(suggestions: suggestions, onSuggestion: onSuggestion)
          else ...[
            _SectionListe(
              titre: 'MES FAVORIS',
              type: 'favoris',
              chants: favoris.valueOrNull ?? const [],
              apercu: _apercu,
              onOuvrir: onOuvrir,
            ),
            _SectionListe(
              titre: 'RÉCEMMENT',
              type: 'historique',
              chants: recents.valueOrNull ?? const [],
              apercu: _apercu,
              onOuvrir: onOuvrir,
            ),
            _SectionListe(
              titre: 'POPULAIRES CETTE SEMAINE',
              type: 'tendances',
              chants: tendances.valueOrNull ?? const [],
              apercu: _apercu,
              onOuvrir: onOuvrir,
            ),
            const SizedBox(height: SignmeSpacing.sm),
            const _Mention(texte: ''),
          ],
        ],
      ),
    );
  }
}

class _SectionListe extends StatelessWidget {
  const _SectionListe({
    required this.titre,
    required this.type,
    required this.chants,
    required this.apercu,
    required this.onOuvrir,
  });

  final String titre;
  final String type;
  final List<ChantReferenceEntity> chants;
  final int apercu;
  final ValueChanged<ChantAOuvrir> onOuvrir;

  @override
  Widget build(BuildContext context) {
    if (chants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _TitreSection(titre)),
            if (chants.length > apercu)
              TextButton(
                onPressed: () => context.pushNamed('chants-liste', pathParameters: {'type': type}),
                child: const Text('Voir tout'),
              ),
          ],
        ),
        for (final c in chants.take(apercu))
          Padding(
            padding: const EdgeInsets.only(bottom: SignmeSpacing.md),
            child: ChantReferenceTile(chant: c, onTap: () => onOuvrir(OuvrirReference(c.uuid, titre: c.titre))),
          ),
        const SizedBox(height: SignmeSpacing.sm),
      ],
    );
  }
}

/// Premier passage : rien encore à montrer, on invite à chercher.
class _Invitation extends StatelessWidget {
  const _Invitation({required this.suggestions, required this.onSuggestion});

  final List<String> suggestions;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: SignmeSpacing.lg),
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: SignmeColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.library_music_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: SignmeSpacing.xl),
        Text('Louez Dieu en chantant', style: SignmeTypography.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: SignmeSpacing.sm),
        Text(
          'Tapez le titre d\'un chant ou quelques mots de ses paroles : '
          'retrouvez-le en vidéo, en paroles ou sur ses sources, sans quitter SignMe. '
          'Les chants que vous regardez se retrouvent ici.',
          style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SignmeSpacing.xxl),
        const Align(alignment: Alignment.centerLeft, child: _TitreSection('ESSAYEZ')),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: SignmeSpacing.sm,
            runSpacing: SignmeSpacing.sm,
            children: [
              for (final s in suggestions) SignmePillChip(label: s, selected: false, onTap: () => onSuggestion(s)),
            ],
          ),
        ),
        const SizedBox(height: SignmeSpacing.xl),
        const _Mention(texte: ''),
      ],
    );
  }
}

class _TitreSection extends StatelessWidget {
  const _TitreSection(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SignmeSpacing.sm, top: SignmeSpacing.sm),
      child: Text(
        texte,
        style: SignmeTypography.labelSmall.copyWith(
          color: SignmeColors.textSecondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Bandeau extends StatelessWidget {
  const _Bandeau({required this.icon, required this.texte});

  final IconData icon;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SignmeSpacing.md),
      padding: const EdgeInsets.all(SignmeSpacing.md),
      decoration: BoxDecoration(
        color: SignmeColors.accentSky,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: SignmeColors.primaryLight),
          const SizedBox(width: SignmeSpacing.sm),
          Expanded(child: Text(texte, style: SignmeTypography.bodySmall)),
        ],
      ),
    );
  }
}

/// « SignMe n'a aucun droit sur les chants proposés » — texte du serveur si présent.
class _Mention extends StatelessWidget {
  const _Mention({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.sm),
      child: Text(
        texte.isEmpty ? kChantsMentionParDefaut : texte,
        textAlign: TextAlign.center,
        style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.textSecondary),
      ),
    );
  }
}
