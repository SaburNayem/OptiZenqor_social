import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/data/service/theme_service.dart';
import 'core/theme/app_theme.dart';
import 'route/routes.dart';

class OptiZenqorApp extends StatelessWidget {
  const OptiZenqorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.mode,
      builder: (_, mode, _) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'OptiZenqor Social',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          getPages: AppPages.routes,
          unknownRoute: AppPages.unknownRoute,
          initialRoute: AppPages.initialRoute,
        );
      },
    );
  }
}
