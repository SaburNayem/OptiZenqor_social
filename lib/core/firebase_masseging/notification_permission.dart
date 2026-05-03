import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../data/api/api_end_points.dart';
import '../data/service/auth_session_service.dart';

final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
bool _isTokenRefreshListenerAttached = false;

Future<bool> requestNotificationPermission() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  final NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final AuthorizationStatus status = settings.authorizationStatus;
  final bool isMessagingAuthorized =
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  bool isLocalNotificationAuthorized = true;
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
  if (androidImplementation != null) {
    isLocalNotificationAuthorized =
        await androidImplementation.requestNotificationsPermission() ?? false;
  }

  return isMessagingAuthorized && isLocalNotificationAuthorized;
}

Future<void> initializePushNotifications({
  bool requestPermissionOnInit = true,
}) async {
  try {
    final bool isGranted = requestPermissionOnInit
        ? await requestNotificationPermission()
        : true;

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    listenTokenRefresh();

    if (!isGranted) {
      return;
    }

    await syncFcmTokenWithBackend();
  } catch (error) {
    debugPrint('[Notifications] initializePushNotifications failed: $error');
  }
}

Future<String?> getFcmToken() async {
  final String? token = await FirebaseMessaging.instance.getToken();
  return token;
}

Future<void> syncFcmTokenWithBackend() async {
  try {
    final String? token = await getFcmToken();
    final normalized = token?.trim() ?? '';
    if (normalized.isEmpty) {
      return;
    }

    await sendFcmTokenToBackend(normalized);
  } catch (error) {
    debugPrint('[Notifications] syncFcmTokenWithBackend failed: $error');
  }
}

Future<void> sendFcmTokenToBackend(String token) async {
  final session = await AuthSessionService().readSession();
  final userToken = session?.accessToken ?? '';
  if (userToken.isEmpty) {
    return;
  }

  final uri = Uri.parse(
    AppConfig.currentApiBaseUrl,
  ).resolve(ApiEndPoints.notificationsDevices);
  final headers = {
    'Authorization': 'Bearer $userToken',
    'Content-Type': 'application/json',
  };
  final body = jsonEncode({
    'token': token,
    'platform': _resolveNotificationPlatform(),
  });
  try {
    await http.post(uri, headers: headers, body: body);
  } catch (error) {
    debugPrint('[Notifications] sendFcmTokenToBackend failed: $error');
  }
}

Future<void> deleteFcmTokenFromBackend([String? currentToken]) async {
  final session = await AuthSessionService().readSession();
  final userToken = session?.accessToken ?? '';
  if (userToken.isEmpty) {
    return;
  }

  final token = (currentToken ?? await getFcmToken())?.trim() ?? '';
  if (token.isEmpty) {
    return;
  }

  final uri = Uri.parse(AppConfig.currentApiBaseUrl).resolve(
    ApiEndPoints.notificationDeviceByToken(Uri.encodeComponent(token)),
  );
  final headers = {
    'Authorization': 'Bearer $userToken',
    'Content-Type': 'application/json',
  };
  try {
    await http.delete(uri, headers: headers);
  } catch (error) {
    debugPrint('[Notifications] deleteFcmTokenFromBackend failed: $error');
  }
}

void listenTokenRefresh() {
  if (_isTokenRefreshListenerAttached) {
    return;
  }
  _isTokenRefreshListenerAttached = true;
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    sendFcmTokenToBackend(newToken);
  });
}

String _resolveNotificationPlatform() {
  if (kIsWeb) {
    return 'web';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'android';
    case TargetPlatform.iOS:
      return 'ios';
    case TargetPlatform.macOS:
      return 'macos';
    case TargetPlatform.windows:
      return 'windows';
    case TargetPlatform.linux:
      return 'linux';
    default:
      return 'unknown';
  }
}
