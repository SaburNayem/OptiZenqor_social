import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/data/service/theme_service.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'feature/bookmarks/controller/bookmarks_controller.dart';
import 'feature/home_feed/controller/home_feed_controller.dart';
import 'feature/home_feed/controller/main_shell_controller.dart';
import 'feature/settings/controller/settings_state_controller.dart';
import 'app_route/app_router.dart';

class OptiZenqorApp extends StatelessWidget {
  const OptiZenqorApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MainShellController>(create: (_) => MainShellController()),
        BlocProvider<HomeFeedController>(create: (_) => HomeFeedController()),
        BlocProvider<BookmarksController>(
          create: (_) => BookmarksController()..load(),
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
            title: 'OptiZenqor Socity',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            navigatorKey: AppNavigator.navigatorKey,
            scaffoldMessengerKey: AppNavigator.scaffoldMessengerKey,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: initialRoute,
          );
        },
      ),
    );
  }
}
