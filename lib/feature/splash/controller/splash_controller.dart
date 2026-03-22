import 'package:flutter/material.dart';

import '../../../route/route_names.dart';

class SplashController {
  Future<void> bootstrap(BuildContext context) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(RouteNames.onboarding);
  }
}
