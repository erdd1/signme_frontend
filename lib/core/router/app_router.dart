import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/main/presentation/screens/main_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/finances/presentation/screens/finances_screen.dart';
import '../../features/historique/presentation/screens/historique_screen.dart';
import '../../features/signature/presentation/screens/ma_carte_screen.dart';
import '../../features/signature/presentation/screens/signer_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../features/users/presentation/screens/user_detail_screen.dart';
import '../../features/users/presentation/screens/my_profile_screen.dart';
import '../../features/anciens/presentation/screens/anciens_designations_screen.dart';
import '../../features/rapports/presentation/screens/rapport_secretaire_screen.dart';
import '../../features/historique_personnel/presentation/screens/historique_personnel_screen.dart';
import '../../features/historique_signatures/presentation/screens/historique_signatures_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// ── Route names ────────────────────────────────────────────────────────────
abstract final class AppRoutes {
  static const splash          = '/';
  static const login           = '/login';
  static const forgotPassword  = '/forgot-password';
  static const home            = '/home';
  static const finances        = '/finances';
  static const historique      = '/historique';
  static const maCarte         = '/ma-carte';
  static const profile         = '/profile';
  static const signer          = '/signer';
  static const users           = '/users';
  static const userDetail      = '/users/:userId';
  static const anciensDesignations = '/anciens-designations';
  static const rapportSecretaire   = '/rapport-secretaire';
  static const historiquePersonnel = '/historique-personnel';
  static const historiqueSignatures = '/historique-signatures';

  /// Construire la route vers le détail d'un utilisateur
  static String userDetailPath(int userId) => '/users/$userId';
}

// ── Router Provider ────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  // En observant l'état auth ici, le router se reconstruira automatiquement
  // lors de la connexion ou de la déconnexion, ce qui garantit la redirection.
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,

    // ── Redirect basé sur l'état Auth ─────────────────────────────────
    redirect: (context, state) {
      // Pas encore initialisé → attendre dans le splash
      if (!authState.isInitialized) {
        return state.matchedLocation == AppRoutes.splash
            ? null
            : AppRoutes.splash;
      }

      final isLoggedIn  = authState.isAuthenticated;
      final loc         = state.matchedLocation;
      final isAuthRoute = loc == AppRoutes.login || loc == AppRoutes.forgotPassword;
      final isSplash    = loc == AppRoutes.splash;

      // Splash → rediriger selon l'état
      if (isSplash) {
        return isLoggedIn ? AppRoutes.home : AppRoutes.login;
      }

      // Non connecté + hors auth → login
      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;

      // Connecté + auth page → home
      if (isLoggedIn && isAuthRoute) return AppRoutes.home;

      return null;
    },

    // On peut garder le listenable pour les changements fins, 
    // mais le watch(authNotifierProvider) ci-dessus est la sécurité ultime.
    refreshListenable: _AuthListenable(ref),

    routes: [
      // ── Splash ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (ctx, state) => _fadePage(const SplashScreen(), state),
      ),

      // ── Auth ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (ctx, state) => _fadePage(const LoginScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        pageBuilder: (ctx, state) => _slidePage(const ForgotPasswordScreen(), state),
      ),

      // ── App Shell ─────────────────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (ctx, state) => _fadePage(const HomeScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.finances,
            name: 'finances',
            pageBuilder: (ctx, state) => _fadePage(const FinancesScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.historique,
            name: 'historique',
            pageBuilder: (ctx, state) => _fadePage(const HistoriqueScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.maCarte,
            name: 'ma-carte',
            pageBuilder: (ctx, state) => _fadePage(const MaCarteScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (ctx, state) => _fadePage(const MyProfileScreen(), state),
          ),
          
          // ── Routes du menu drawer (restent dans le shell) ───────────────
          GoRoute(
            path: AppRoutes.users,
            name: 'users',
            pageBuilder: (ctx, state) => _fadePage(const UsersScreen(), state),
            routes: [
              // Sous-route pour afficher le détail d'un utilisateur
              GoRoute(
                path: ':userId',
                name: 'user-detail',
                pageBuilder: (ctx, state) {
                  final userId = int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
                  return _fadePage(UserDetailScreen(userId: userId), state);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.anciensDesignations,
            name: 'anciens-designations',
            pageBuilder: (ctx, state) => _fadePage(const AncienDesignationsScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.rapportSecretaire,
            name: 'rapport-secretaire',
            pageBuilder: (ctx, state) => _fadePage(const RapportSecretaireScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.historiquePersonnel,
            name: 'historique-personnel',
            pageBuilder: (ctx, state) => _fadePage(const HistoriquePersonnelScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.historiqueSignatures,
            name: 'historique-signatures',
            pageBuilder: (ctx, state) => _fadePage(const HistoriqueSignaturesScreen(), state),
          ),
        ],
      ),

      // ── Signer (bottom sheet plein écran - peut être indépendant) ──────
      GoRoute(
        path: AppRoutes.signer,
        name: 'signer',
        pageBuilder: (ctx, state) => _slidePage(const SignerScreen(), state),
      ),
    ],

    errorPageBuilder: (ctx, state) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text('Page introuvable : ${state.error}'),
        ),
      ),
    ),
  );
});

// ── Listenables pour refreshListenable ─────────────────────────────────────
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    _subscription = ref.listen(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

// ── Transitions ────────────────────────────────────────────────────────────
CustomTransitionPage<void> _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key:                state.pageKey,
    child:              child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

CustomTransitionPage<void> _slidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key:                state.pageKey,
    child:              child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end:   Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}
