import 'package:flutter/material.dart';

import 'app_router.dart';
import 'route_names.dart';

class RouteGenerator {
  RouteGenerator._();

  static const initialRoute = RouteNames.splash;

  static Route<dynamic> generate(RouteSettings settings) {
    return AppRouter.onGenerateRoute(settings);
  }
}
