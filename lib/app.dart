import 'package:flutter/material.dart';

import 'core/data/service/theme_service.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'route/app_router.dart';

class OptiZenqorApp extends StatelessWidget {
  const OptiZenqorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.mode,
      builder: (_, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'OptiZenqor Social',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          navigatorKey: AppNavigator.navigatorKey,
          scaffoldMessengerKey: AppNavigator.scaffoldMessengerKey,
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: AppRouter.initialRoute,
        );
      },
    );
  }
}
