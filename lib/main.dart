import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/config/app_environment.dart';
import 'core/deep_link/deep_link_listener.dart';
import 'core/local/isar_service.dart';
import 'core/notifications/push_notification_listener.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/utils/app_logger.dart';
import 'core/widgets/app_error_fallback.dart';
import 'core/widgets/keyboard_dismiss_scope.dart';
import 'features/auth/presentation/widgets/session_expired_listener.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';

void main() {
  // ── Filet de sécurité global ─────────────────────────────────────────────
  // runZonedGuarded capte toute exception ASYNCHRONE non interceptée
  // ailleurs (Future/Timer/Stream sans try/catch) — sans lui, une telle
  // erreur remonte à la zone racine et peut faire planter l'app en release.
  // FlutterError.onError capte les erreurs du FRAMEWORK (build/layout/paint)
  // — Flutter les affiche déjà sans planter l'app entière, on ajoute juste
  // la journalisation. PlatformDispatcher.onError capte le reste (callbacks
  // de plateforme hors zone Flutter). Dans les trois cas : on journalise et
  // l'app continue, elle ne s'arrête jamais sur une erreur imprévue.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Écran de secours si un widget précis échoue à se construire — jamais
    // l'écran technique gris/rouge par défaut de Flutter devant un vrai
    // utilisateur, surtout en release.
    ErrorWidget.builder = (FlutterErrorDetails details) => AppErrorFallback(details: details);

    // ── Garde-fou publication (voir AppEnvironment.assertValidForRelease) ──
    AppEnvironment.assertValidForRelease();

    // ── Notifications push (Firebase Cloud Messaging) ──────────────────────
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Remontée automatique des crashs — désactivée en debug (sessions de
    // développement/hot-reload) pour ne pas polluer le tableau de bord avec
    // du bruit ; active en profile/release, là où de vrais utilisateurs
    // sont exposés à un éventuel bug.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.error('Erreur Flutter non interceptée', details.exception);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      AppLogger.error('Erreur plateforme non interceptée', error);
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true; // gérée : n'interrompt pas l'app
    };

    // ── Base de données locale (Offline-First) ─────────────────────────────
    await IsarService.init();

    // ── Locale française ────────────────────────────────────────────────────
    await initializeDateFormatting('fr_FR', null);
    timeago.setLocaleMessages('fr', timeago.FrMessages());

    // ── Orientation portrait uniquement ───────────────────────────────────
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // ── Barre de statut transparente ───────────────────────────────────────
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:           Colors.transparent,
      statusBarIconBrightness:  Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    runApp(const ProviderScope(child: SignMeApp()));
  }, (error, stack) {
    AppLogger.error('Erreur non interceptée (zone racine)', error);
    // Try/catch défensif : si l'erreur survient avant que Firebase ait fini
    // de s'initialiser, Crashlytics n'est pas encore utilisable — ne jamais
    // faire planter le gestionnaire d'erreurs lui-même.
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } catch (_) {}
  });
}

class SignMeApp extends ConsumerWidget {
  const SignMeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // ── Configuration ──────────────────────────────────────────────────
      title:            AppStrings.appName,
      debugShowCheckedModeBanner: false,
      routerConfig:     router,
      theme:            AppTheme.lightTheme,

      // ── Localization ──────────────────────────────────────────────────
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),

      // ── Builder : applique Poppins même aux widgets système ───────────
      builder: (context, child) {
        return DeepLinkListener(
          child: PushNotificationListener(
            child: SessionExpiredListener(
              child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.2,
                ),
              ),
              // Clavier refermable partout (toucher dehors, barre « Terminé » iOS).
              child: KeyboardDismissScope(child: child ?? const SizedBox.shrink()),
              ),
            ),
          ),
        );
      },
    );
  }
}
