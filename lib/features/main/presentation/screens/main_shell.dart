import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/notifications/push_notification_provider.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/badge_dot.dart';
import '../../../../core/widgets/keyboard_avoiding_body.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/role_menu_drawer.dart';
import '../../../../core/widgets/signme_unsaved_changes_guard.dart';
import '../../../../core/websocket/ws_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../badge/domain/entities/badge_count_entity.dart';
import '../../../badge/presentation/providers/badge_provider.dart';
import '../../../groupes/presentation/providers/groupes_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../signature/presentation/providers/ma_carte_provider.dart';
import '../../../finances/presentation/providers/finances_provider.dart';
import '../../../rapports/presentation/providers/rapports_provider.dart';
import '../../../anciens/presentation/providers/anciens_provider.dart';
import '../../../evenements/presentation/providers/evenements_provider.dart';
import '../../../home/presentation/providers/home_feed_provider.dart';

import '../../../historique_personnel/presentation/providers/historique_personnel_combined_provider.dart';
import '../../../historique_signatures/presentation/providers/historique_signatures_provider.dart';

const double _kNavHeight = 76.0;
const double _kFabSize = 62.0;
const double _kFabLift = 24.0;
const double _kNavHPad = 16.0;
const double _kNavBPad = 12.0;

/// Sur iPhone, la zone de sécurité du bas (~34 pt) est occupée par la barre
/// d'accueil, qui n'a que quelques points de hauteur : la navbar peut s'y
/// enfoncer de cette valeur sans la toucher.
const double _kHomeIndicatorOverlap = 14.0;
const double _kNavRadius = 28.0;

/// Hauteur totale occupée par la navbar flottante (navbar + relevé du FAB),
/// hors zone de sécurité système. À ajouter à
/// `MediaQuery.of(context).padding.bottom` pour calculer le padding bas d'un
/// écran vivant derrière [MainShell] (tous les écrans du ShellRoute), afin
/// que son dernier élément ne soit jamais masqué par la navbar — une valeur
/// fixe ne peut jamais convenir à la fois aux appareils à navigation gestuelle
/// (zone de sécurité quasi nulle) et à ceux à barre de navigation 3-boutons
/// (zone de sécurité nettement plus haute).
const double kFloatingNavClearance = _kNavBPad + _kNavHeight + _kFabLift;

/// Marge basse d'un écran vivant derrière [MainShell] : navbar flottante +
/// zone de sécurité système. Méthode unique pour que le dernier élément d'une
/// liste ne soit jamais masqué, sur iPhone comme sur Android (voir
/// [kFloatingNavClearance]).
double floatingNavInset(BuildContext context) =>
    kFloatingNavClearance + MediaQuery.of(context).padding.bottom;

/// Distance entre le bas de l'écran et la navbar flottante.
///
/// Sur iPhone à barre d'accueil, la navbar se pose juste au-dessus de celle-ci
/// (≈ 20 pt) au lieu de flotter 46 pt plus haut ; ailleurs (Android, iPhone à
/// bouton), elle garde sa marge habituelle au-dessus de la zone de sécurité.
double floatingNavBottomOffset({required double safeBottom, required TargetPlatform platform}) {
  if (platform != TargetPlatform.iOS) return _kNavBPad + safeBottom;

  return math.max(safeBottom - _kHomeIndicatorOverlap, _kNavBPad);
}

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.auth?.user;

    if (!authState.isAuthenticated || user == null) {
      return child;
    }

    // ── WebSocket : connexion/déconnexion selon l'état d'auth ──────────────
    ref.watch(syncBootstrapProvider);
    // ── Préchargement des modules non couverts par SyncService (état en
    // mémoire, indépendant du cache Isar) — actifs dès le login, peu importe
    // l'onglet ouvert par l'utilisateur.
    ref.watch(maCarteBootstrapProvider);
    ref.watch(financesBootstrapProvider);
    ref.watch(rapportSecretaireBootstrapProvider);
    ref.watch(ancienBootstrapProvider);
    ref.watch(evenementsGestionBootstrapProvider);
    ref.watch(historiquePersonnelBootstrapProvider);
    ref.watch(historiqueSignaturesBootstrapProvider);


    // ── Notifications push : filet de sécurité pour une session déjà
    // restaurée avant le premier build (le ref.listen ci-dessous ne capte
    // que les transitions non connecté → connecté).
    ensureDeviceTokenRegistered(ref, authState.isAuthenticated);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        final userId  = next.auth?.user.id ?? 0;
        final churchId = next.auth?.user.churchId ?? 0;
        if (churchId > 0) {
          ref.read(wsClientProvider).connect(
            churchId: churchId,
            userId:   userId,
          );
        }
        // ── Notifications push : enregistre le jeton de cet appareil ──────
        ensureDeviceTokenRegistered(ref, true);
      } else if (!next.isAuthenticated) {
        ref.read(wsClientProvider).disconnect();
        if (previous?.isAuthenticated == true) {
          unregisterDeviceToken(ref);
          resetDeviceTokenRegistrationFlag();
        }
      }
    });

    final tabs = AppPermissions.getNavTabs(user);
    final currentIdx = _currentIndex(context, tabs);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Masquer la navbar quand le clavier est ouvert
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // Écrans de service : plein écran (ni appbar ni navbar du shell), tout en
    // restant dans le shell pour pouvoir ouvrir ses autres écrans.
    final fullScreen = _isFullScreenRoute(GoRouterState.of(context).matchedLocation);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: SignmeColors.white,
      drawer: const RoleMenuDrawer(),
      // Pas de menu par glissement sur un écran plein écran (il a sa flèche de retour).
      drawerEnableOpenDragGesture: !fullScreen,
      appBar: fullScreen
          ? null
          : AppBar(
        backgroundColor: SignmeColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: _buildAppBarTitleForRoute(context),
        actions: [
          if (GoRouterState.of(context).matchedLocation == AppRoutes.home) ...[
            Builder(
              builder: (ctx) => Padding(
                padding: const EdgeInsets.only(right: SignmeSpacing.sm),
                child: IconButton(
                  icon: const Icon(Icons.menu_rounded,
                      color: SignmeColors.black, size: 28),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          // Le contenu se réduit avec le clavier pour que le champ en cours de
          // saisie reste visible ; la navbar, elle, garde sa position (elle se
          // masque déjà quand le clavier s'ouvre).
          KeyboardAvoidingBody(child: child),
          // ── Bannière hors ligne ──
          Positioned(
            // Sans appbar du shell, la bannière se place sous la barre d'état.
            top: fullScreen ? MediaQuery.of(context).padding.top : 0,
            left: 0,
            right: 0,
            child: const OfflineBanner(),
          ),
          // ── Navbar: Positioned D'ABORD, animations À L'INTÉRIEUR ──
          if (!fullScreen)
          Positioned(
            left: _kNavHPad,
            right: _kNavHPad,
            bottom: floatingNavBottomOffset(safeBottom: bottomInset, platform: defaultTargetPlatform),
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              offset: keyboardVisible ? const Offset(0, 1.5) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: keyboardVisible ? 0.0 : 1.0,
                child: _FloatingNavBar(
                  tabs: tabs,
                  currentIndex: currentIdx,
                  isTabRoute: _isTabRoute(context, tabs),
                  onNavTap: (t) => _onNavTap(context, ref, t),
                  fab: _buildFab(context, ref, user),
                ),
              ),
            ),
          ),
          // ── Assistant religieux : accueil uniquement, au-dessus de la
          // navbar côté Profil (à la manière du bouton IA de WhatsApp) ──
          if (GoRouterState.of(context).matchedLocation == AppRoutes.home)
            Positioned(
              right: _kNavHPad + SignmeSpacing.xs,
              bottom: floatingNavBottomOffset(safeBottom: bottomInset, platform: defaultTargetPlatform) +
                  _kNavHeight +
                  SignmeSpacing.md,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                offset: keyboardVisible ? const Offset(0, 1.5) : Offset.zero,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: keyboardVisible ? 0.0 : 1.0,
                  child: _AssistantFab(onTap: () => context.push(AppRoutes.assistant)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitleForRoute(BuildContext context) {
    final route = GoRouterState.of(context).matchedLocation;
    final String label = switch (route) {
      AppRoutes.home => "SignMe",
      AppRoutes.finances => "Mes Finances",
      AppRoutes.services => "Services",
      AppRoutes.historiquePersonnel => "Mon Historique",
      AppRoutes.profile => "Mon Profil",
      AppRoutes.maCarte => "Ma Carte",
      AppRoutes.users => "Gérer utilisateurs",
      AppRoutes.signer => "Signer une carte",
      AppRoutes.anciensDesignations => "Anciens de services",
      AppRoutes.rapportSecretaire => "Rapport secrétaire",
      AppRoutes.historiqueSignatures => "Historique Signatures",
      AppRoutes.publications => "Gérer publications",
      AppRoutes.parametres => "Paramètres",
      AppRoutes.userCreate => "Nouveau membre",
      AppRoutes.userStats => "Statistiques fidèles",
      AppRoutes.evenementCreate => "Créer un événement",
      AppRoutes.gestionEvenements => "Gérer les événements",
      AppRoutes.contributionsEvenement => "Contributions événement",
      AppRoutes.sortiesFinancieres => "Sorties financières",
      AppRoutes.retraits => "Retraits",
      AppRoutes.mesDepenses => "Mes dépenses",
      AppRoutes.aboutChurch => "À propos de votre Église",
      AppRoutes.celebrations => "Célébrations",
      _ when route.startsWith('${AppRoutes.users}/') &&
          route.endsWith('/edit') =>
      "Modifier le membre",
      _ when route.startsWith('${AppRoutes.users}/') => "Détails utilisateur",
      _ when route.startsWith('/evenements/') && !route.endsWith('/contribuer') =>
      "Détail de l'événement",
      _ => "SignMe",
    };
    final fontSize = route == AppRoutes.home ? 24.0 : 20.0;
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [SignmeColors.primaryDark, SignmeColors.primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: SignmeColors.white,
          fontWeight: FontWeight.w900,
          fontSize: fontSize,
        ),
      ),
    );
  }

  /// Routes du shell affichées en plein écran, comme l'écran d'un groupe :
  /// l'écran porte sa propre flèche de retour et son titre.
  bool _isFullScreenRoute(String route) =>
      route == AppRoutes.servicesDon ||
      route == AppRoutes.servicesGestionActualites ||
      route == AppRoutes.servicesGestionFinance ||
      route == AppRoutes.servicesRapportSignatures;

  bool _isTabRoute(BuildContext ctx, List<NavTab> tabs) {
    final loc = GoRouterState.of(ctx).matchedLocation;
    return tabs.any((t) => _routeMatches(loc, t));
  }

  bool _routeMatches(String loc, NavTab t) => switch (t) {
    NavTab.home => loc == AppRoutes.home,
    NavTab.finances => loc == AppRoutes.finances,
    NavTab.services => loc == AppRoutes.services,
    NavTab.profile => loc == AppRoutes.profile,
    NavTab.maCarte => loc == AppRoutes.maCarte,
  };

  int _currentIndex(BuildContext ctx, List<NavTab> tabs) {
    final loc = GoRouterState.of(ctx).matchedLocation;
    for (int i = 0; i < tabs.length; i++) {
      if (_routeMatches(loc, tabs[i])) return i;
    }
    return 0;
  }

  /// Point de passage UNIQUE pour toute navigation déclenchée depuis la
  /// coquille (navbar, FAB) : ces actions utilisent `go()` (remplace la
  /// pile de routes) et non `pop()`, donc [SignmeUnsavedChangesGuard] (qui
  /// n'intercepte que les retours) ne les couvre pas. On consulte ici le
  /// même [formDirtyProvider] et on affiche la même confirmation avant de
  /// laisser passer la navigation, pour ne jamais perdre une saisie en
  /// cours d'un tap accidentel sur un autre onglet.
  Future<void> _guardedNavigate(
      BuildContext ctx,
      WidgetRef ref,
      VoidCallback navigate,
      ) async {
    if (ref.read(formDirtyProvider)) {
      final confirmed = await confirmDiscardChanges(ctx);
      if (!confirmed) return;
      ref.read(formDirtyProvider.notifier).state = false;
    }
    navigate();
  }

  void _onNavTap(BuildContext ctx, WidgetRef ref, NavTab tab) {
    // Retaper sur l'onglet déjà actif : remonte le contenu en haut plutôt
    // que de renaviguer (même geste que WhatsApp sur l'item "Discussions").
    if (tab == NavTab.home && GoRouterState.of(ctx).matchedLocation == AppRoutes.home) {
      final controller = ref.read(homeScrollControllerProvider);
      if (controller.hasClients) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }

    _guardedNavigate(ctx, ref, () {
      // ── Reset badge + rafraîchissement silencieux de l'onglet tapé ──────
      // Depuis le passage à StatefulShellRoute.indexedStack (onglets gardés
      // vivants — plus de reconstruction complète à chaque bascule), les
      // `initState` de ces écrans (qui rafraîchissaient à chaque OUVERTURE)
      // ne se redéclenchent plus après la première visite : on reproduit ce
      // même rafraîchissement ici, au moment du tap, pour un comportement
      // utilisateur identique à avant.
      switch (tab) {
        case NavTab.home:
          // Ne marque comme lu que l'onglet Actualités actuellement
          // sélectionné (Événements/Annonces/Méditations) — les deux autres
          // gardent leur badge tant que l'utilisateur ne les a pas ouverts
          // (voir _ActualitesTabs dans home_screen.dart pour le même geste
          // au moment où l'utilisateur bascule d'onglet sans quitter Home).
          ref.read(badgeNotifierProvider.notifier).markRead(
                ref.read(selectedActualiteCategoryProvider).badgeType,
              );
        case NavTab.services:
          // Catalogue statique ; seul l'aperçu des transactions se rafraîchit,
          // et le badge « nouvelle transaction » repart de zéro.
          ref.invalidate(recentTransactionsProvider);
          ref.read(transactionsBadgeProvider.notifier).markRead();
        case NavTab.finances:
          ref.read(financesProvider.notifier).refreshSilently();
        case NavTab.maCarte:
          ref.read(maCarteProvider.notifier).refreshSilently();
        case NavTab.profile:
          ref.read(authNotifierProvider.notifier).refreshProfile();
      }

      ctx.go(switch (tab) {
        NavTab.home => AppRoutes.home,
        NavTab.finances => AppRoutes.finances,
        NavTab.services => AppRoutes.services,
        NavTab.profile => AppRoutes.profile,
        NavTab.maCarte => AppRoutes.maCarte,
      });
    });
  }

  Widget _buildFab(BuildContext ctx, WidgetRef ref, UserEntity user) {
    if (!user.actif) {
      return const SizedBox(
        width: _kFabSize,
        height: _kFabSize,
      );
    }

    // Paroissien non communiant : le bouton reste affiché (toujours présent
    // dans la navbar) mais ne peut pas signer sa carte — un tap l'explique.
    if (!user.estCommuniant) {
      return _DockedFab(
        icon: Icons.add_rounded,
        onTap: () => AppSnackbar.info(
          ctx,
          'La signature de carte est réservée aux membres communiants.',
        ),
      );
    }

    return _DockedFab(
      icon: Icons.add_rounded,
      onTap: () => _guardedNavigate(ctx, ref, () => ctx.go(AppRoutes.signer)),
    );
  }
}

// ── Navbar flottante avec FAB encastré ──────────────────────────────────
// ConsumerWidget dédié (plutôt qu'un `ref.watch(badgeNotifierProvider)` dans
// MainShell.build()) : les compteurs de badges changent souvent (polling
// 60s + événements WebSocket temps réel) — les regarder ici confine le
// rebuild à cette seule navbar au lieu de reconstruire tout le Scaffold
// (AppBar + Drawer + cette même navbar, dont le flou BackdropFilter est l'un
// des rendus les plus coûteux de Flutter) à chaque mise à jour.
class _FloatingNavBar extends ConsumerWidget {
  const _FloatingNavBar({
    required this.tabs,
    required this.currentIndex,
    required this.isTabRoute,
    required this.onNavTap,
    required this.fab,
  });

  final List<NavTab> tabs;
  final int currentIndex;
  final bool isTabRoute;
  final void Function(NavTab) onNavTap;
  final Widget fab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(badgeNotifierProvider).valueOrNull ?? BadgeCountEntity.empty;
    // Nouveautés des groupes (communiqués, transactions) : badge de l'onglet
    // Services, actualisé toutes les 60 s comme les autres badges.
    ref.watch(groupesBadgePollingProvider);
    final groupesNonLus = ref.watch(groupesNonLusTotalProvider);
    // Nouvelles transactions (tout type) : même badge Services. Si l'utilisateur
    // est déjà sur Services quand elles arrivent, il les voit tout de suite :
    // on les marque lues sans attendre qu'il quitte l'onglet.
    final transactionsNonLues = ref.watch(transactionsBadgeProvider);
    final onServices = currentIndex == tabs.indexOf(NavTab.services) && isTabRoute;
    ref.listen<int>(transactionsBadgeProvider, (_, next) {
      if (onServices && next > 0) ref.read(transactionsBadgeProvider.notifier).markRead();
    });
    int badgeCountForTab(NavTab tab) => switch (tab) {
      NavTab.home => badges.annonces + badges.meditations + badges.evenements,
      NavTab.services => groupesNonLus + transactionsNonLues + badges.historiqueSignatures,
      _ => 0,
    };
    final half = tabs.length ~/ 2;

    return SizedBox(
      height: _kNavHeight + _kFabLift,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ── Fond arrondi avec trou + Glassmorphism ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _kNavHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_kNavRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_kNavRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: CustomPaint(
                    painter: _NotchedNavPainter(
                      color: SignmeColors.surface.withValues(alpha: 0.85),
                      radius: _kNavRadius,
                      notchRadius: _kFabSize / 2 + 8,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Items de navigation gauche ──
          Positioned(
            left: 0,
            bottom: 0,
            height: _kNavHeight,
            width: (MediaQuery.of(context).size.width - _kNavHPad * 2) / 2 -
                _kFabSize / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: tabs.sublist(0, half).map((t) {
                return Expanded(
                  child: _NavItem(
                    tab: t,
                    isActive: currentIndex == tabs.indexOf(t) && isTabRoute,
                    badgeCount: badgeCountForTab(t),
                    onTap: () => onNavTap(t),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Items de navigation droite ──
          Positioned(
            right: 0,
            bottom: 0,
            height: _kNavHeight,
            width: (MediaQuery.of(context).size.width - _kNavHPad * 2) / 2 -
                _kFabSize / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: tabs.sublist(half).map((t) {
                return Expanded(
                  child: _NavItem(
                    tab: t,
                    isActive: currentIndex == tabs.indexOf(t) && isTabRoute,
                    badgeCount: badgeCountForTab(t),
                    onTap: () => onNavTap(t),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── FAB centré, encastré dans l'encoche ──
          Positioned(
            bottom: (_kNavHeight / 2) - (_kFabSize / 2),
            left: 0,
            right: 0,
            child: Center(child: fab),
          ),
        ],
      ),
    );
  }
}

// ── Painter : fond blanc arrondi + encoche circulaire centrale ────────────
class _NotchedNavPainter extends CustomPainter {
  const _NotchedNavPainter({
    required this.color,
    required this.radius,
    required this.notchRadius,
  });

  final Color color;
  final double radius;
  final double notchRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const margin = 6.0;
    final nr = notchRadius + margin;

    final path = Path()
      ..moveTo(radius, 0)
      ..lineTo(cx - nr, 0)
      ..arcToPoint(
        Offset(cx + nr, 0),
        radius: Radius.circular(nr),
        clockwise: false,
      )
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(Offset(size.width, radius),
          radius: Radius.circular(radius))
      ..lineTo(size.width, size.height - radius)
      ..arcToPoint(Offset(size.width - radius, size.height),
          radius: Radius.circular(radius))
      ..lineTo(radius, size.height)
      ..arcToPoint(Offset(0, size.height - radius),
          radius: Radius.circular(radius))
      ..lineTo(0, radius)
      ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
      ..close();

    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.20),
      14,
      false,
    );

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_NotchedNavPainter old) =>
      old.color != color ||
          old.radius != radius ||
          old.notchRadius != notchRadius;
}

// ── FAB premium ─────────────────────────────────────────────────────────
class _DockedFab extends StatelessWidget {
  const _DockedFab({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kFabSize,
      height: _kFabSize,
      child: Semantics(
        button: true,
        label: 'Signer une carte',
        excludeSemantics: true,
        onTap: onTap,
        child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SignmeColors.primaryDark,
                SignmeColors.primaryLight,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: SignmeColors.primaryDark.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: SignmeColors.onPrimary,
            size: 28,
          ),
        ),
      ),
      ),
    );
  }
}

// ── NavItem avec badge ───────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  final NavTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final icon = switch (tab) {
      NavTab.home => isActive ? Icons.home_rounded : Icons.home_outlined,
      NavTab.finances =>
      isActive ? Icons.bar_chart_rounded : Icons.bar_chart_outlined,
      NavTab.services =>
      isActive ? Icons.grid_view_rounded : Icons.grid_view_outlined,
      NavTab.profile =>
      isActive ? Icons.person_rounded : Icons.person_outline_rounded,
      NavTab.maCarte =>
      isActive ? Icons.credit_card_rounded : Icons.credit_card_outlined,
    };
    final label = switch (tab) {
      NavTab.home => "Accueil",
      NavTab.finances => "Finances",
      NavTab.services => 'Services',
      NavTab.profile => 'Profil',
      NavTab.maCarte => "Ma Carte",
    };

    return Semantics(
      button: true,
      selected: isActive,
      label: badgeCount > 0 ? '$label, $badgeCount nouveauté${badgeCount > 1 ? 's' : ''}' : label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Icône avec badge ─────────────────────────────────────────
          BadgeDot(
            count: badgeCount,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SignmeSpacing.sm,
                vertical: SignmeSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? SignmeColors.primaryLight.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive
                    ? SignmeColors.primaryLight
                    : SignmeColors.black,
              ),
            ),
          ),
          const SizedBox(height: SignmeSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: SignmeTypography.labelSmall.copyWith(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? SignmeColors.primaryLight : SignmeColors.black,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ── Bouton flottant « Assistant religieux » ─────────────────────────────
class _AssistantFab extends StatelessWidget {
  const _AssistantFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Assistant religieux',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SignmeColors.primaryGradientLinear,
                boxShadow: [
                  BoxShadow(
                    color: SignmeColors.primaryLight.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(height: SignmeSpacing.xs),
            Text(
              'Assistant\nreligieux',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                height: 1.15,
                fontWeight: FontWeight.w700,
                color: SignmeColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
