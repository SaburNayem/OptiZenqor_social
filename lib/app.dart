import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'route/route_generator.dart';

class OptiZenqorApp extends StatelessWidget {
  const OptiZenqorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OptiZenqor Social',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: RouteGenerator.generate,
      initialRoute: RouteGenerator.initialRoute,
    );
  }
}
