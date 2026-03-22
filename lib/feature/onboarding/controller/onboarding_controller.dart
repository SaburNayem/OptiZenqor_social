import 'package:flutter/material.dart';

import '../../../route/route_names.dart';

class OnboardingController {
  final PageController pageController = PageController();
  int index = 0;

  bool get isLast => index == 2;

  void onPageChanged(int value, VoidCallback onChanged) {
    index = value;
    onChanged();
  }

  void next(BuildContext context, VoidCallback onChanged) {
    if (isLast) {
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
    index++;
    onChanged();
  }

  void skip(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(RouteNames.login);
  }

  void dispose() {
    pageController.dispose();
  }
}
