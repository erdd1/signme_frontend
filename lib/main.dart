import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'features/auth/presentation/widgets/session_expired_listener.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Garde-fou publication (voir AppEnvironment.assertValidForRelease) ────
  AppEnvironment.assertValidForRelease();

  // ── Notifications push (Firebase Cloud Messaging) ────────────────────────
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ── Base de données locale (Offline-First) ───────────────────────────────
  await IsarService.init();

  // ── Locale française ────────────────────────────────────────────────────
  await initializeDateFormatting('fr_FR', null);
  timeago.setLocaleMessages('fr', timeago.FrMessages());

  // ── Orientation portrait uniquement ─────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Barre de statut transparente ─────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:           Colors.transparent,
    statusBarIconBrightness:  Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const ProviderScope(child: SignMeApp()));
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
              child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
