import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/data/service/theme_service.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'features/home_feed/controller/home_feed_controller.dart';
import 'features/home_feed/controller/main_shell_controller.dart';
import 'features/settings/controller/settings_state_controller.dart';
import 'route/app_router.dart';

class OptiZenqorApp extends StatelessWidget {
  const OptiZenqorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MainShellController>(create: (_) => MainShellController()),
        BlocProvider<HomeFeedController>(
          create: (_) => HomeFeedController()..loadInitial(),
        ),
        BlocProvider<SettingsStateController>(
          create: (_) => SettingsStateController()..load(),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
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
      ),
    );
  }
}
