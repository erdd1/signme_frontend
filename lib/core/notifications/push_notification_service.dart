import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handler top-level requis par FCM pour les messages reçus app fermée ou en
/// arrière-plan (doit être une fonction top-level ou statique). Rien à faire
/// ici : l'OS affiche déjà la notification système automatiquement pour les
/// messages de type "notification" dans ce cas — seul le premier plan (où
/// l'OS n'affiche rien par défaut) nécessite un affichage manuel.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Service — Notifications push (Firebase Cloud Messaging) : permission,
/// jeton d'appareil, affichage en premier plan, navigation au tap.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const _androidChannel = AndroidNotificationChannel(
    'signme_default',
    'SignMe',
    description: 'Notifications SignMe (publications, événements, anniversaires)',
    importance: Importance.high,
  );

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// [onNotificationTap] reçoit le payload `data` du message pour naviguer
  /// vers le bon écran (ex. {'type': 'publication', 'id': '42'}).
  Future<void> initialize({
    required void Function(Map<String, dynamic> data) onNotificationTap,
  }) async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          onNotificationTap(Map<String, dynamic>.from(jsonDecode(payload) as Map));
        } catch (_) {}
      },
    );

    // Premier plan : l'OS n'affiche rien automatiquement — on l'affiche nous-même.
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // Tap sur la notification alors que l'app était en arrière-plan.
    FirebaseMessaging.onMessageOpenedApp.listen((message) => onNotificationTap(message.data));

    // App ouverte directement depuis une notification (était fermée).
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      onNotificationTap(initialMessage.data);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    try {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] Échec affichage notification locale: $e');
    }
  }

  Future<String?> getToken() => _messaging.getToken();

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  String get platform => Platform.isIOS ? 'ios' : 'android';
}
