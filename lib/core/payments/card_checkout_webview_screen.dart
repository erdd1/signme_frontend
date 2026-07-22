import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/api_config.dart';
import '../design_system/index.dart';

/// Écran WebView pour le paiement par carte bancaire (NotchPay).
///
/// Charge la page de paiement hébergée par NotchPay (`authorizationUrl`).
/// L'utilisateur y saisit ses informations de carte — nous ne manipulons
/// jamais ces données nous-mêmes (conformité PCI-DSS). Dès que la
/// navigation atteint la page de callback (`/payment/callback`, servie par
/// notre propre backend), l'écran se ferme automatiquement : le statut réel
/// du paiement provient toujours du webhook/polling existant, jamais de
/// cette page de retour.
class CardCheckoutWebViewScreen extends StatefulWidget {
  const CardCheckoutWebViewScreen({super.key, required this.authorizationUrl});

  final String authorizationUrl;

  /// Retourne `true` si l'utilisateur a atteint la page de callback
  /// (paiement terminé, réussi ou non), `false` s'il a fermé manuellement
  /// avant. Dans les deux cas, le polling/webhook existant reste la seule
  /// source de vérité sur le statut réel du paiement.
  static Future<bool> open(BuildContext context, String authorizationUrl) async {
    // rootNavigator: true — le shell principal (MainShell) dessine sa navbar
    // flottante en Positioned PAR-DESSUS le contenu de la route active. Un
    // push sur le Navigator imbriqué du ShellRoute resterait "sous" cette
    // navbar (elle la recouvrirait). Pousser sur le Navigator racine sort
    // l'écran de paiement de ce Stack et couvre bien tout l'écran.
    final result = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (_) => CardCheckoutWebViewScreen(authorizationUrl: authorizationUrl),
        fullscreenDialog: true,
      ),
    );
    return result ?? false;
  }

  @override
  State<CardCheckoutWebViewScreen> createState() => _CardCheckoutWebViewScreenState();
}

class _CardCheckoutWebViewScreenState extends State<CardCheckoutWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (_isCallbackUrl(url)) {
              _closeWithResult(true);
              return;
            }
            setState(() => _isLoading = true);
          },
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            if (_isCallbackUrl(request.url)) {
              _closeWithResult(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  /// Vérifie à la fois le chemin ET l'hôte : une page tierce qui contiendrait
  /// par coïncidence "/payment/callback" dans son chemin (ex. redirection
  /// publicitaire au sein de la page hébergée NotchPay) ne doit jamais être
  /// confondue avec notre propre page de callback.
  bool _isCallbackUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.path.contains('/payment/callback')) return false;

    final apiHost = Uri.tryParse(ApiConfig.baseUrl)?.host;
    return apiHost == null || uri.host == apiHost;
  }

  void _closeWithResult(bool result) {
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SignmeColors.white,
        foregroundColor: SignmeColors.black,
        elevation: 0.5,
        title: Text(
          'Paiement par carte',
          style: SignmeTypography.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _closeWithResult(false),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: SignmeColors.primaryLight),
              ),
          ],
        ),
      ),
    );
  }
}
