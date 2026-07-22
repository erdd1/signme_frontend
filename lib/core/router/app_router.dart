import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/main/presentation/screens/main_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/finances/presentation/screens/finances_screen.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/signature/presentation/screens/ma_carte_screen.dart';
import '../../features/signature/presentation/screens/signer_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/welcome/presentation/screens/welcome_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../features/users/presentation/screens/user_detail_screen.dart';
import '../../features/users/presentation/screens/create_edit_user_screen.dart';
import '../../features/users/presentation/screens/gestion_utilisateurs_screen.dart';
import '../../features/anciens/presentation/screens/anciens_designations_screen.dart';
import '../../features/rapports/presentation/screens/rapport_secretaire_screen.dart';
import '../../features/historique_personnel/presentation/screens/historique_personnel_screen.dart';
import '../../features/historique_signatures/presentation/screens/historique_signatures_screen.dart';
import '../../features/publications/presentation/screens/publications_list_screen.dart';
import '../../features/publications/presentation/screens/publication_detail_screen.dart';
import '../../features/publications/presentation/screens/create_edit_publication_screen.dart';
import '../../features/parametres/presentation/screens/parametres_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/evenements/presentation/screens/create_edit_evenement_screen.dart';
import '../../features/evenements/presentation/screens/contribution_form_screen.dart';
import '../../features/evenements/presentation/screens/contributions_evenement_screen.dart';
import '../../features/evenements/presentation/screens/gestion_evenements_screen.dart';
import '../../features/evenements/domain/entities/evenement_entity.dart';
import '../../features/mes_depenses/presentation/screens/mes_depenses_screen.dart';
import '../deep_link/deep_link_state.dart';

// ── Route names ────────────────────────────────────────────────────────────
abstract final class AppRoutes {
  static const splash          = '/';
  static const welcome         = '/welcome';
  static const login           = '/login';
  static const forgotPassword  = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const resetPassword   = '/reset-password';
  static const home            = '/home';
  static const finances        = '/finances';
  static const historique      = '/historique';
  static const maCarte         = '/ma-carte';
  static const profile         = '/profile';
  static const changePassword  = '/profile/change-password';
  static const signer          = '/signer';
  static const users           = '/users';
  static const userCreate      = '/users/create';
  static const userStats       = '/users/stats';

  static String userDetailPath(int userId) => '/users/$userId';
  static String userEditPath(int userId) => '/users/$userId/edit';
  static const anciensDesignations = '/anciens-designations';
  static const rapportSecretaire   = '/rapport-secretaire';
  static const historiquePersonnel = '/historique-personnel';
  static const historiqueSignatures = '/historique-signatures';
  static const publications = '/publications';
  static const publicationCreate = '/publications/create';
  static const parametres = '/parametres';

  static String publicationDetailPath(int id) => '/publications/$id';
  static String publicationEditPath(int id) => '/publications/$id/edit';

  // ── Événements (module collecte de fonds) ────────────────────────────────
  static const evenementCreate = '/evenements/create';
  static const gestionEvenements = '/evenements/gestion';
  static const contributionsEvenement = '/contributions-evenement';
  static String contributionFormPath(String evenementUuid) =>
      '/evenements/$evenementUuid/contribuer';

  // ── Mes dépenses ──────────────────────────────────────────────────────────
  static const mesDepenses = '/mes-depenses';
}

// ── Router Provider ────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  // Ne pas watch authNotifierProvider ici : chaque refresh profil recréait
  // GoRouter (initialLocation splash → redirect /home) et quittait /profile.
  final authListenable = _AuthListenable(ref);
  ref.onDispose(authListenable.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,

    // ── Redirect basé sur l'état Auth ─────────────────────────────────
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);

      // Pas encore initialisé → attendre dans le splash
      if (!authState.isInitialized) {
        return state.matchedLocation == AppRoutes.splash
            ? null
            : AppRoutes.splash;
      }

      final isLoggedIn  = authState.isAuthenticated;
      final loc         = state.matchedLocation;
      final isResetRoute = loc.startsWith(AppRoutes.resetPassword);
      final isOtpRoute  = loc.startsWith(AppRoutes.otpVerification);
      final isAuthRoute = loc == AppRoutes.login ||
          loc == AppRoutes.forgotPassword ||
          loc == AppRoutes.welcome ||
          isResetRoute ||
          isOtpRoute;
      final isSplash    = loc == AppRoutes.splash;
      final pendingDeep = ref.read(pendingDeepLinkProvider);

      // Splash → deep link reset prioritaire, sinon welcome/home
      if (isSplash) {
        if (pendingDeep != null) return pendingDeep;
        return isLoggedIn ? AppRoutes.home : AppRoutes.welcome;
      }

      // Non connecté + hors auth → welcome
      if (!isLoggedIn && !isAuthRoute) return AppRoutes.welcome;

      // Connecté + auth (sauf reset) → home
      if (isLoggedIn && isAuthRoute && !isResetRoute) return AppRoutes.home;

      return null;
    },

    refreshListenable: authListenable,

    routes: [
      // ── Splash ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (ctx, state) => _fadePage(const SplashScreen(), state),
      ),

      // ── Welcome ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        pageBuilder: (ctx, state) => _fadePage(const WelcomeScreen(), state),
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
        pageBuilder: (ctx, state) =>
            _authFlowPage(const ForgotPasswordScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otp-verification',
        pageBuilder: (ctx, state) {
          final email = state.uri.queryParameters['email'];
          return _authFlowPage(
            OTPVerificationScreen(email: email ?? ''),
            state,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'reset-password',
        pageBuilder: (ctx, state) {
          final email = state.uri.queryParameters['email'];
          final token = state.uri.queryParameters['token'];
          final resetToken = state.uri.queryParameters['reset_token'];
          return _authFlowPage(
            ResetPasswordScreen(
              initialEmail: email,
              initialToken: token,
              initialResetToken: resetToken,
            ),
            state,
          );
        },
      ),

      // ── App Shell ─────────────────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (ctx, state) => const HomeScreen(),
          ),

          GoRoute(
            path: AppRoutes.finances,
            name: 'finances',
            builder: (ctx, state) => const FinancesScreen(),
          ),

          GoRoute(
            path: AppRoutes.historique,
            name: 'historique',
            builder: (ctx, state) => const HistoriquePersonnelScreen(),
          ),

          GoRoute(
            path: AppRoutes.maCarte,
            name: 'ma-carte',
            builder: (ctx, state) => const MaCarteScreen(),
          ),

          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (ctx, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'change-password',
                name: 'change-password',
                pageBuilder: (ctx, state) =>
                    _authFlowPage(const ChangePasswordScreen(), state),
              ),
            ],
          ),

          // ── Signer (Intégré dans le Shell désormais) ──────────────────
          GoRoute(
            path: AppRoutes.signer,
            name: 'signer',
            pageBuilder: (ctx, state) => _fadePage(const SignerScreen(), state),
          ),
          
          // ── Routes du menu drawer (restent dans le shell) ───────────────
          GoRoute(
            path: AppRoutes.users,
            name: 'users',
            pageBuilder: (ctx, state) => _fadePage(const UsersScreen(), state),
            routes: [
              GoRoute(
                path: 'create',
                name: 'user-create',
                pageBuilder: (ctx, state) =>
                    _fadePage(const CreateEditUserScreen(), state),
              ),
              // AVANT :userId pour éviter le conflit de capture.
              GoRoute(
                path: 'stats',
                name: 'user-stats',
                pageBuilder: (ctx, state) =>
                    _fadePage(const GestionUtilisateursScreen(), state),
              ),
              GoRoute(
                path: ':userId',
                name: 'user-detail',
                pageBuilder: (ctx, state) {
                  final userId =
                      int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
                  return _fadePage(UserDetailScreen(userId: userId), state);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'user-edit',
                    pageBuilder: (ctx, state) {
                      final userId =
                          int.tryParse(state.pathParameters['userId'] ?? '') ??
                              0;
                      return _fadePage(
                        CreateEditUserScreen(userId: userId),
                        state,
                      );
                    },
                  ),
                ],
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
          GoRoute(
            path: AppRoutes.publications,
            name: 'publications',
            pageBuilder: (ctx, state) =>
                _fadePage(const PublicationsListScreen(), state),
            routes: [
              GoRoute(
                path: 'create',
                name: 'publication-create',
                pageBuilder: (ctx, state) => _fadePage(
                  const CreateEditPublicationScreen(),
                  state,
                ),
              ),
              GoRoute(
                path: ':id',
                name: 'publication-detail',
                pageBuilder: (ctx, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return _fadePage(
                    PublicationDetailScreen(publicationId: id),
                    state,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'publication-edit',
                    pageBuilder: (ctx, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return _fadePage(
                        CreateEditPublicationScreen(publicationId: id),
                        state,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.parametres,
            name: 'parametres',
            pageBuilder: (ctx, state) => _fadePage(const ParametresScreen(), state),
          ),

          // ── Événements (module collecte de fonds) ───────────────────────
          GoRoute(
            path: AppRoutes.evenementCreate,
            name: 'evenement-create',
            pageBuilder: (ctx, state) => _fadePage(const CreateEditEvenementScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.gestionEvenements,
            name: 'gestion-evenements',
            pageBuilder: (ctx, state) => _fadePage(const GestionEvenementsScreen(), state),
          ),
          GoRoute(
            path: '/evenements/:uuid/contribuer',
            name: 'evenement-contribuer',
            pageBuilder: (ctx, state) {
              final evenement = state.extra as EvenementEntity;
              return _fadePage(ContributionFormScreen(evenement: evenement), state);
            },
          ),
          GoRoute(
            path: AppRoutes.contributionsEvenement,
            name: 'contributions-evenement',
            pageBuilder: (ctx, state) =>
                _fadePage(const ContributionsEvenementScreen(), state),
          ),

          // ── Mes dépenses ─────────────────────────────────────────────────
          GoRoute(
            path: AppRoutes.mesDepenses,
            name: 'mes-depenses',
            pageBuilder: (ctx, state) => _fadePage(const MesDepensesScreen(), state),
          ),
        ],
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

  ref.onDispose(router.dispose);
  return router;
});

// ── Listenables pour refreshListenable ─────────────────────────────────────
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    _subscription = ref.listen(
      authNotifierProvider,
      (previous, next) {
        final prevInit = previous?.isInitialized ?? false;
        final nextInit = next.isInitialized;
        final prevAuth = previous?.isAuthenticated ?? false;
        final nextAuth = next.isAuthenticated;
        if (prevInit != nextInit || prevAuth != nextAuth) {
          notifyListeners();
        }
      },
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

/// Transition fluide entre écrans du flux auth (push depuis login).
CustomTransitionPage<void> _authFlowPage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.12, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
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
