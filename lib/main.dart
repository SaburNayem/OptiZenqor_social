import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'app_route/app_router.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/config/app_config.dart';
import 'core/data/service/network_status_service.dart';
import 'core/data/service/theme_service.dart';
import 'core/firebase_masseging/notification_permission.dart';
import 'core/firebase_masseging/notification_receive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
      if (details.stack != null) {
        debugPrint('${details.stack}');
      }
    }
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[PlatformError] $error');
      debugPrint('$stackTrace');
    }
    return false;
  };

  if (kDebugMode) {
    debugPrint('[DebugConsole] Verbose app logging enabled');
    debugPrint('[AppConfig] API base URL: ${AppConfig.currentApiBaseUrl}');
    final String? networkHint = AppConfig.debugLocalNetworkHint;
    if (networkHint != null) {
      debugPrint('[AppConfig] $networkHint');
    }
  }

  runApp(const OptiZenqorApp(initialRoute: AppRouter.initialRoute));
  unawaited(_initializeStartupServices());
  unawaited(NetworkStatusService.instance.start());
}

Future<void> _initializeStartupServices() async {
  try {
    await ThemeService.instance.init();
    await ensureFirebaseInitialized();
    await FirebaseNotificationReceive.initializeLocalNotifications();
    FirebaseNotificationReceive.setupBackgroundMessageHandler();
    await FirebaseNotificationReceive.registerInteractionHandlers();
    await initializePushNotifications(requestPermissionOnInit: false);
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('[StartupServices] Initialization failed: $error');
      debugPrint('$stackTrace');
    }
  }
}
