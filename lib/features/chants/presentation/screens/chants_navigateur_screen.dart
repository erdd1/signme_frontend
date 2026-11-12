import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/chant_navigateur.dart';
import '../../domain/entities/chant_hub_entities.dart';
import '../providers/chants_provider.dart';

/// Ce que le navigateur doit ouvrir : la recherche du chrétien, dans un moteur.
class ChantsNavigateurArgs {
  const ChantsNavigateurArgs({required this.requete, required this.moteur});

  final String requete;
  final MoteurRecherche moteur;
}

/// Navigateur intégré à SignMe : les vraies pages de résultats de Google et de
/// YouTube, et la lecture des vidéos, sans jamais quitter l'application.
///
/// Une vidéo YouTube regardée est retenue toute seule dans « Mes chants » (titre
/// + lien, jamais le contenu) ; n'importe quelle autre page se garde d'un geste.
class ChantsNavigateurScreen extends ConsumerStatefulWidget {
  const ChantsNavigateurScreen({super.key, required this.args});

  final ChantsNavigateurArgs args;

  @override
  ConsumerState<ChantsNavigateurScreen> createState() => _ChantsNavigateurScreenState();
}

class _ChantsNavigateurScreenState extends ConsumerState<ChantsNavigateurScreen> {
  late final WebViewController _controller;
  late MoteurRecherche _moteur = widget.args.moteur;

  Uri? _url;
  int _progression = 0;
  bool _peutReculer = false;
  bool _peutAvancer = false;
  bool _enCours = false;

  /// Chants déjà retenus pendant cette visite (identifiant de vidéo ou adresse).
  final Set<String> _gardes = {};
  Timer? _delaiTitre;

  /// Vidéo plein écran (Android) : le lecteur de la page prend tout l'écran.
  Widget? _pleinEcran;
  VoidCallback? _quitterPleinEcran;

  @override
  void initState() {
    super.initState();

    // iOS : lecture vidéo dans la page (sinon YouTube force le plein écran natif à chaque fois).
    final PlatformWebViewControllerCreationParams params = WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
          )
        : const PlatformWebViewControllerCreationParams();

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // YouTube et Google en ont besoin
      ..setBackgroundColor(SignmeColors.white)
      ..setNavigationDelegate(NavigationDelegate(
        // Seuls http(s) sont suivis : jamais intent:, market:, file:, javascript:…
        onNavigationRequest: (req) => ChantNavigateur.schemeAutorise(req.url)
            ? NavigationDecision.navigate
            : NavigationDecision.prevent,
        onPageStarted: (_) => setState(() => _enCours = true),
        onProgress: (p) => setState(() => _progression = p),
        onPageFinished: (url) {
          setState(() => _enCours = false);
          _actualiser(Uri.tryParse(url));
        },
        // Les sites comme YouTube changent de page sans la recharger : on suit l'adresse.
        onUrlChange: (change) => _actualiser(Uri.tryParse(change.url ?? '')),
      ));

    final plateforme = _controller.platform;
    if (plateforme is AndroidWebViewController) {
      plateforme.setCustomWidgetCallbacks(
        onShowCustomWidget: (widget, onHidden) => setState(() {
          _pleinEcran = widget;
          _quitterPleinEcran = onHidden;
        }),
        onHideCustomWidget: () => setState(() {
          _pleinEcran = null;
          _quitterPleinEcran = null;
        }),
      );
    }

    _controller.loadRequest(_moteur.urlPour(widget.args.requete));
  }

  @override
  void dispose() {
    _delaiTitre?.cancel();
    super.dispose();
  }

  Future<void> _actualiser(Uri? uri) async {
    if (uri == null || !mounted) return;
    final reculer = await _controller.canGoBack();
    final avancer = await _controller.canGoForward();
    if (!mounted) return;
    setState(() {
      _url = uri;
      _peutReculer = reculer;
      _peutAvancer = avancer;
    });

    // Une vidéo YouTube regardée est retenue toute seule — après un court instant,
    // le temps que la page affiche son vrai titre.
    final id = ChantNavigateur.idVideoYoutube(uri);
    if (id != null && !_gardes.contains(id)) {
      _delaiTitre?.cancel();
      _delaiTitre = Timer(const Duration(milliseconds: 1500), () => _retenir(automatique: true));
    }
  }

  /// Retient la page affichée dans « Mes chants » (titre + lien).
  Future<void> _retenir({required bool automatique}) async {
    final courante = await _controller.currentUrl();
    final uri = courante == null ? _url : Uri.tryParse(courante);
    if (uri == null || !mounted) return;

    final id = ChantNavigateur.idVideoYoutube(uri);
    final cle = id ?? uri.toString();
    if (_gardes.contains(cle)) return;
    if (id == null && !ChantNavigateur.estEnregistrable(uri)) return;

    final titreBrut = await _controller.getTitle();
    final titre = ChantNavigateur.titrePropre(titreBrut, repli: id == null ? uri.host : 'Vidéo YouTube');

    final ChantAOuvrir cible = id != null
        ? OuvrirVideo(ChantVideoEntity(embedId: id, titre: titre, thumb: ChantNavigateur.vignette(id)))
        : OuvrirWeb(titre: titre, url: uri.toString());

    _gardes.add(cle); // avant l'appel : jamais deux enregistrements pour la même page
    try {
      await ref.read(chantsRemoteDataSourceProvider).vu(cible);
      rafraichirAccueilChants(ref);
      if (mounted) {
        setState(() {}); // le bouton « Garder » devient « Dans vos chants »
        if (automatique) AppSnackbar.success(context, 'Ajouté à vos chants');
      }
    } catch (e) {
      _gardes.remove(cle); // un échec réseau ne doit pas empêcher de réessayer
      if (mounted && !automatique) AppSnackbar.error(context, 'Impossible de garder ce chant pour le moment.');
    }
  }

  void _changerMoteur(MoteurRecherche moteur) {
    if (moteur == _moteur) return;
    setState(() => _moteur = moteur);
    _controller.loadRequest(moteur.urlPour(widget.args.requete));
  }

  Future<void> _retour() async {
    if (_pleinEcran != null) {
      _quitterPleinEcran?.call();
      return;
    }
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else if (mounted) {
      context.canPop() ? context.pop() : context.go(AppRoutes.chants);
    }
  }

  bool get _dejaGarde {
    final uri = _url;
    if (uri == null) return false;
    return _gardes.contains(ChantNavigateur.idVideoYoutube(uri) ?? uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final uri = _url;
    final peutGarder = uri != null && (ChantNavigateur.idVideoYoutube(uri) != null || ChantNavigateur.estEnregistrable(uri));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _retour();
      },
      child: Scaffold(
        backgroundColor: SignmeColors.white,
        appBar: AppBar(
          backgroundColor: SignmeColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: SignmeColors.black),
            tooltip: 'Fermer',
            onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.chants),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              for (final m in MoteurRecherche.values) ...[
                SignmePillChip(label: m.libelle, selected: m == _moteur, onTap: () => _changerMoteur(m)),
                const SizedBox(width: SignmeSpacing.sm),
              ],
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: _enCours && _progression < 100
                ? LinearProgressIndicator(value: _progression / 100, minHeight: 3, color: SignmeColors.primaryLight)
                : const SizedBox(height: 3),
          ),
        ),
        body: _pleinEcran != null
            ? _pleinEcran!
            : Column(
                children: [
                  Expanded(child: WebViewWidget(controller: _controller)),
                  _BarreBas(
                    peutReculer: _peutReculer,
                    peutAvancer: _peutAvancer,
                    onReculer: _controller.goBack,
                    onAvancer: _controller.goForward,
                    onActualiser: _controller.reload,
                    garde: _dejaGarde,
                    onGarder: peutGarder && !_dejaGarde ? () => _retenir(automatique: false) : null,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Précédent / suivant / actualiser, et « Garder ce chant » pour retenir la page affichée.
class _BarreBas extends StatelessWidget {
  const _BarreBas({
    required this.peutReculer,
    required this.peutAvancer,
    required this.onReculer,
    required this.onAvancer,
    required this.onActualiser,
    required this.garde,
    required this.onGarder,
  });

  final bool peutReculer;
  final bool peutAvancer;
  final VoidCallback onReculer;
  final VoidCallback onAvancer;
  final VoidCallback onActualiser;
  final bool garde;
  final VoidCallback? onGarder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SignmeColors.white,
        border: Border(top: BorderSide(color: SignmeColors.lightGrayBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.sm, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                tooltip: 'Page précédente',
                onPressed: peutReculer ? onReculer : null,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                tooltip: 'Page suivante',
                onPressed: peutAvancer ? onAvancer : null,
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Actualiser',
                onPressed: onActualiser,
              ),
              const Spacer(),
              if (garde)
                const Padding(
                  padding: EdgeInsets.only(right: SignmeSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: SignmeColors.success, size: 20),
                      SizedBox(width: 6),
                      Text('Dans vos chants', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                )
              else
                TextButton.icon(
                  onPressed: onGarder,
                  icon: const Icon(Icons.library_add_rounded, size: 20),
                  label: const Text('Garder ce chant'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
