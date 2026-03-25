import 'package:flutter/material.dart';

import 'app_pages.dart';
import 'route_names.dart';

class RouteGenerator {
  RouteGenerator._();

  static const initialRoute = RouteNames.splash;

  static Route<dynamic> generate(RouteSettings settings) {
    final builder = AppPages.pageBuilders[settings.name];
    if (builder != null) {
      return _buildRoute(builder(), settings);
    }
    return _buildRoute(
      Scaffold(
        body: Center(child: Text('No route found for ${settings.name}')),
      ),
      settings,
    );
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(builder: (_) => page, settings: settings);
  }
}
