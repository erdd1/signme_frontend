import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/entities/chant_entity.dart';
import '../../domain/entities/chant_hub_entities.dart';
import '../providers/chants_provider.dart';
import '../widgets/chant_text_size_sheet.dart';
import '../widgets/lyrics_section_view.dart';
import 'chants_screen.dart' show kChantsMentionParDefaut;

/// Fiche d'un chant : lecteur vidéo intégré, paroles ou page web, avec toujours
/// le lien vers la source. Plein écran, hors coquille : lecture sans distraction.
///
/// Ouvrir la fiche enregistre le chant dans mon historique (titre + lien
/// seulement) : je le retrouve ensuite en touchant son titre.
class ChantDetailScreen extends ConsumerStatefulWidget {
  const ChantDetailScreen({super.key, required this.cible});

  final ChantAOuvrir cible;

  @override
  ConsumerState<ChantDetailScreen> createState() => _ChantDetailScreenState();
}

class _ChantDetailScreenState extends ConsumerState<ChantDetailScreen> {
  late Future<ChantOuvertureEntity> _future;
  ChantOuvertureEntity? _ouverture;

  @override
  void initState() {
    super.initState();
    _future = _charger();
  }

  Future<ChantOuvertureEntity> _charger() async {
    final remote = ref.read(chantsRemoteDataSourceProvider);
    final ouverture = switch (widget.cible) {
      OuvrirReference(:final uuid) => await remote.ouvrir(uuid),
      final autre => await remote.vu(autre),
    };
    if (mounted) setState(() => _ouverture = ouverture);
    return ouverture;
  }

  void _recharger() => setState(() {
        _ouverture = null;
        _future = _charger();
      });

  Future<void> _basculerFavori() async {
    final actuel = _ouverture;
    if (actuel == null) return;
    final remote = ref.read(chantsRemoteDataSourceProvider);

    setState(() => _ouverture = actuel.copyWith(favori: !actuel.favori)); // optimiste
    try {
      actuel.favori ? await remote.retirerFavori(actuel.uuid) : await remote.ajouterFavori(actuel.uuid);
      ref.invalidate(chantsFavorisProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() => _ouverture = actuel);
      AppSnackbar.error(context, messageFromError(e));
    }
  }

  Future<void> _ouvrirSource(String url) async {
    final ouvert = await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
    if (!ouvert && mounted) AppSnackbar.error(context, 'Impossible d\'ouvrir la source.');
  }

  Future<void> _signaler(ChantOuvertureEntity ouverture) async {
    final controller = TextEditingController();
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
        backgroundColor: SignmeColors.white,
        title: Text('Signaler ce chant', style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contenu inapproprié, lien trompeur ou chant dont vous détenez les droits ? '
              'Dites-nous pourquoi (facultatif).',
              style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.mediumGray),
            ),
            const SizedBox(height: SignmeSpacing.md),
            TextField(
              controller: controller,
              maxLength: 255,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Motif', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Signaler')),
        ],
      ),
    );
    final motif = controller.text.trim();
    controller.dispose();
    if (confirme != true || !mounted) return;

    try {
      await ref
          .read(chantsRemoteDataSourceProvider)
          .signaler(ouverture.uuid, motif: motif.isEmpty ? null : motif);
      if (mounted) AppSnackbar.success(context, 'Merci : votre signalement a été pris en compte.');
    } catch (e) {
      if (mounted) AppSnackbar.error(context, messageFromError(e));
    }
  }

  void _partager(ChantOuvertureEntity o, ChantDetailEntity? paroles) {
    final texte = paroles != null
        ? '${_titreArtiste(paroles.title, paroles.artist)}\n\n${paroles.plainText}\n\nPartagé depuis SignMe'
        : '${o.titre}\n${o.url ?? ''}\n\nPartagé depuis SignMe';
    Share.share(texte.trim(), subject: o.titre);
  }

  Future<void> _copier(ChantDetailEntity paroles) async {
    await Clipboard.setData(
      ClipboardData(text: '${_titreArtiste(paroles.title, paroles.artist)}\n\n${paroles.plainText}'),
    );
    if (mounted) AppSnackbar.success(context, 'Paroles copiées');
  }

  static String _titreArtiste(String titre, String artiste) => artiste.isEmpty ? titre : '$titre — $artiste';

  @override
  Widget build(BuildContext context) {
    final o = _ouverture;
    final paroles = o != null && o.source == ChantSource.paroles && o.lyricsId != null
        ? ref.watch(chantDetailProvider(o.lyricsId!)).asData?.value
        : null;

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.chants),
        ),
        title: Text(
          o?.source == ChantSource.paroles ? 'Paroles' : 'Chant',
          style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (o?.source == ChantSource.paroles)
            IconButton(
              icon: const Icon(Icons.text_fields_rounded, color: SignmeColors.primaryLight),
              tooltip: 'Taille du texte',
              onPressed: () => showChantTextSizeSheet(context),
            ),
          if (o != null) ...[
            IconButton(
              icon: Icon(
                o.favori ? Icons.star_rounded : Icons.star_border_rounded,
                color: o.favori ? const Color(0xFFF5A623) : SignmeColors.primaryLight,
              ),
              tooltip: o.favori ? 'Retirer des favoris' : 'Ajouter aux favoris',
              onPressed: _basculerFavori,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: SignmeColors.primaryLight),
              onSelected: (valeur) {
                switch (valeur) {
                  case 'partager':
                    _partager(o, paroles);
                  case 'copier':
                    if (paroles != null) _copier(paroles);
                  case 'signaler':
                    _signaler(o);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'partager', child: Text('Partager')),
                if (paroles != null) const PopupMenuItem(value: 'copier', child: Text('Copier les paroles')),
                const PopupMenuItem(value: 'signaler', child: Text('Signaler')),
              ],
            ),
          ],
        ],
      ),
      body: FutureBuilder<ChantOuvertureEntity>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final e = snapshot.error!;
            return SignmeErrorState(
              title: e is AppException && e.statusCode == 410 ? 'Chant retiré' : 'Chant indisponible',
              message: messageFromError(e),
              icon: e is NetworkException ? Icons.wifi_off_rounded : Icons.error_outline,
              onRetry: e is AppException && e.statusCode == 410 ? null : _recharger,
            );
          }
          final ouverture = _ouverture;
          if (!snapshot.hasData || ouverture == null) {
            return ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(SignmeSpacing.lg),
              children: const [
                SignmeSkeleton(width: double.infinity, height: 120, borderRadius: SignmeSpacing.radiusLg),
                SizedBox(height: SignmeSpacing.lg),
                SignmeSkeletonList(itemCount: 3, itemHeight: 150),
              ],
            );
          }
          return _Contenu(ouverture: ouverture, onOuvrirSource: _ouvrirSource);
        },
      ),
    );
  }
}

class _Contenu extends ConsumerWidget {
  const _Contenu({required this.ouverture, required this.onOuvrirSource});

  final ChantOuvertureEntity ouverture;
  final Future<void> Function(String url) onOuvrirSource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final o = ouverture;

    return ListView(
      padding: EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.lg, SignmeSpacing.lg, SignmeSpacing.xxxl + safeBottom),
      children: [
        _Entete(titre: o.titre, artiste: o.artiste, source: o.source),
        const SizedBox(height: SignmeSpacing.lg),
        if (!o.disponible)
          _Indisponible(titre: o.titre, onOuvrirSource: o.url == null ? null : () => onOuvrirSource(o.url!))
        else ...[
          switch (o.source) {
            ChantSource.youtube => _LecteurVideo(embedId: o.embedId!),
            ChantSource.paroles => _Paroles(lyricsId: o.lyricsId!),
            ChantSource.web => _PageWeb(url: o.url!, onOuvrir: () => onOuvrirSource(o.url!)),
          },
          if (o.source == ChantSource.youtube && o.url != null) ...[
            const SizedBox(height: SignmeSpacing.lg),
            _Source(url: o.url!, onOuvrir: () => onOuvrirSource(o.url!)),
          ],
        ],
        const SizedBox(height: SignmeSpacing.xl),
        Text(
          o.mention.isEmpty ? kChantsMentionParDefaut : o.mention,
          style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Entete extends StatelessWidget {
  const _Entete({required this.titre, required this.artiste, required this.source});

  final String titre;
  final String? artiste;
  final ChantSource source;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SignmeSpacing.xl),
      decoration: BoxDecoration(
        gradient: SignmeColors.primaryGradientLinear,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            switch (source) {
              ChantSource.youtube => Icons.play_circle_rounded,
              ChantSource.paroles => Icons.music_note_rounded,
              ChantSource.web => Icons.public_rounded,
            },
            color: Colors.white70,
            size: 28,
          ),
          const SizedBox(height: SignmeSpacing.md),
          Text(titre, style: SignmeTypography.headlineLarge.copyWith(color: Colors.white)),
          if (artiste != null) ...[
            const SizedBox(height: SignmeSpacing.xs),
            Text(artiste!, style: SignmeTypography.bodyMedium.copyWith(color: Colors.white70)),
          ],
        ],
      ),
    );
  }
}

/// Lecteur officiel YouTube intégré : la vidéo se lit dans l'app, au premier plan.
class _LecteurVideo extends StatefulWidget {
  const _LecteurVideo({required this.embedId});

  final String embedId;

  @override
  State<_LecteurVideo> createState() => _LecteurVideoState();
}

class _LecteurVideoState extends State<_LecteurVideo> {
  late final YoutubePlayerController _controller = YoutubePlayerController.fromVideoId(
    videoId: widget.embedId,
    autoPlay: false,
    params: const YoutubePlayerParams(
      showFullscreenButton: true,
      strictRelatedVideos: true, // les suggestions restent celles de la même chaîne
      enableCaption: false,
    ),
  );

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      child: YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
    );
  }
}

/// Paroles complètes (strophes, refrains) — récupérées à la source à chaque ouverture.
class _Paroles extends ConsumerWidget {
  const _Paroles({required this.lyricsId});

  final int lyricsId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(chantDetailProvider(lyricsId));
    final scale = ref.watch(chantTextScaleProvider);

    return async.when(
      loading: () => const SignmeSkeletonList(itemCount: 3, itemHeight: 150),
      error: (e, _) => SignmeErrorState(
        title: 'Paroles indisponibles',
        message: messageFromError(e),
        icon: e is NetworkException ? Icons.wifi_off_rounded : Icons.error_outline,
        onRetry: () => ref.invalidate(chantDetailProvider(lyricsId)),
      ),
      data: (chant) {
        var strophe = 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chant.versions.length > 1) ...[
              _Versions(chant: chant),
              const SizedBox(height: SignmeSpacing.lg),
            ],
            for (final section in chant.sections) ...[
              LyricsSectionView(
                section: section,
                textScale: scale,
                strophe: section.type == LyricsSectionType.strophe ? ++strophe : null,
              ),
              const SizedBox(height: SignmeSpacing.md),
            ],
            Text(
              'Paroles fournies par ${chant.sourceName}.',
              style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

/// Sélecteur de version : un chip par interprète ; toucher une autre version la
/// remplace (et l'enregistre à son tour).
class _Versions extends StatelessWidget {
  const _Versions({required this.chant});

  final ChantDetailEntity chant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VERSIONS DISPONIBLES',
          style: SignmeTypography.labelSmall.copyWith(
            color: SignmeColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: SignmeSpacing.sm),
        Wrap(
          spacing: SignmeSpacing.sm,
          runSpacing: SignmeSpacing.sm,
          children: [
            for (final v in chant.versions)
              SignmePillChip(
                label: v.artist.isEmpty ? 'Version ${v.id}' : v.artist,
                selected: v.id == chant.id,
                onTap: () {
                  if (v.id == chant.id) return;
                  context.pushReplacementNamed(
                    'chant-detail',
                    extra: OuvrirParoles(ChantSummaryEntity(
                      id: v.id,
                      title: chant.title,
                      artist: v.artist,
                      excerpt: const [],
                      versions: chant.versions,
                    )),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// Page d'un site : on l'ouvre dans le navigateur intégré, sans quitter SignMe.
class _PageWeb extends StatelessWidget {
  const _PageWeb({required this.url, required this.onOuvrir});

  final String url;
  final VoidCallback onOuvrir;

  @override
  Widget build(BuildContext context) {
    final hote = Uri.tryParse(url)?.host ?? url;

    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.public_rounded, size: 40, color: SignmeColors.primaryLight),
          const SizedBox(height: SignmeSpacing.md),
          Text(hote, style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: SignmeSpacing.lg),
          SignmePrimaryButton(label: 'Ouvrir la page', icon: Icons.open_in_new_rounded, onPressed: onOuvrir),
        ],
      ),
    );
  }
}

/// Lien vers la source d'un chant, toujours proposé.
class _Source extends StatelessWidget {
  const _Source({required this.url, required this.onOuvrir});

  final String url;
  final VoidCallback onOuvrir;

  @override
  Widget build(BuildContext context) {
    final hote = (Uri.tryParse(url)?.host ?? url).replaceFirst('www.', '');

    return InkWell(
      onTap: onOuvrir,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(SignmeSpacing.md),
        decoration: BoxDecoration(
          color: SignmeColors.accentSky.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        ),
        child: Row(
          children: [
            const Icon(Icons.link_rounded, color: SignmeColors.primaryLight),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Source', style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.textSecondary)),
                  Text(hote, style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 18, color: SignmeColors.primaryLight),
          ],
        ),
      ),
    );
  }
}

/// La source n'existe plus (vidéo supprimée, lien cassé) : on le dit clairement
/// et on propose de chercher ce chant autrement.
class _Indisponible extends StatelessWidget {
  const _Indisponible({required this.titre, required this.onOuvrirSource});

  final String titre;
  final VoidCallback? onOuvrirSource;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.xl),
      decoration: BoxDecoration(
        color: SignmeColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          const Icon(Icons.link_off_rounded, size: 40, color: SignmeColors.error),
          const SizedBox(height: SignmeSpacing.md),
          Text('Source indisponible', style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: SignmeSpacing.sm),
          Text(
            'Cette vidéo ou cette page n\'existe plus. Cherchez ce chant pour en trouver une autre version.',
            textAlign: TextAlign.center,
            style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.darkGray, height: 1.4),
          ),
          const SizedBox(height: SignmeSpacing.lg),
          SignmePrimaryButton(
            label: 'Chercher ce chant',
            icon: Icons.search_rounded,
            onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.chants),
          ),
          if (onOuvrirSource != null) ...[
            const SizedBox(height: SignmeSpacing.sm),
            SignmeSecondaryButton(label: 'Essayer la source', icon: Icons.open_in_new_rounded, onPressed: onOuvrirSource),
          ],
        ],
      ),
    );
  }
}
