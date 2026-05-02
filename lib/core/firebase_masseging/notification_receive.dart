import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../../feature/notifications/controller/notifications_controller.dart';

Future<FirebaseApp> ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) {
    return Firebase.app();
  }

  return Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await ensureFirebaseInitialized();

  await FirebaseNotificationReceive.showNotification(message);
}

@pragma('vm:entry-point')
void notificationTapBackgroundHandler(NotificationResponse response) {
  FirebaseNotificationReceive.handleLocalNotificationTap(response);
}

class FirebaseNotificationReceive {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'default_channel',
        'Default Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );
  static bool _interactionHandlersRegistered = false;

  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: handleLocalNotificationTap,
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackgroundHandler,
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.createNotificationChannel(_defaultChannel);
  }

  static void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show Android notification in status bar
      showNotification(message);
    });
  }

  static void setupBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> registerInteractionHandlers() async {
    if (_interactionHandlersRegistered) {
      return;
    }
    _interactionHandlersRegistered = true;

    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageTap);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _handleRemoteMessageTap(initialMessage);
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? 'You have a new message',
      notificationDetails: details,
      payload: message.data.isEmpty ? null : jsonEncode(message.data),
    );
  }

  static void handleLocalNotificationTap(NotificationResponse response) {
    _routePayload(response.payload);
  }

  static Future<void> _handleRemoteMessageTap(RemoteMessage message) async {
    await _routeMessageData(message.data);
  }

  static Future<void> _routePayload(String? payload) async {
    final normalized = payload?.trim() ?? '';
    if (normalized.isEmpty) {
      await _routeMessageData(const <String, dynamic>{});
      return;
    }

    try {
      final decoded = jsonDecode(normalized);
      if (decoded is Map) {
        await _routeMessageData(Map<String, dynamic>.from(decoded));
        return;
      }
    } catch (error) {
      debugPrint(
        '[Notifications] Failed to decode notification payload: $error',
      );
    }

    await _routeMessageData(const <String, dynamic>{});
  }

  static Future<void> _routeMessageData(Map<String, dynamic> data) async {
    final controller = NotificationsController();
    await controller.openPushPayload(data);
    controller.dispose();
  }
}
