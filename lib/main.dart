import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'app_route/app_router.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/config/app_config.dart';
import 'core/data/service/theme_service.dart';
import 'core/firebase_masseging/notification_permission.dart';
import 'core/firebase_masseging/notification_receive.dart';
import 'feature/splash/controller/splash_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ensureFirebaseInitialized();
  await FirebaseNotificationReceive.initializeLocalNotifications();
  FirebaseNotificationReceive.setupBackgroundMessageHandler();
  await FirebaseNotificationReceive.registerInteractionHandlers();
  await initializePushNotifications();
  await ThemeService.instance.init();
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

  String initialRoute = AppRouter.initialRoute;
  try {
    initialRoute = await SplashController().resolveInitialRoute();
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('[StartupRoute] Falling back to default route: $error');
      debugPrint('$stackTrace');
    }
  }

  runApp(OptiZenqorApp(initialRoute: initialRoute));
}
