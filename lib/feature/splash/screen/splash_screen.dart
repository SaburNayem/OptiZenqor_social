import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final SplashController _splashController = SplashController();
  final ValueNotifier<bool> _bootstrapped = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    if (!_bootstrapped.value) {
      _bootstrapped.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _splashController.bootstrap(context);
      });
    }
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 84,
                height: 84,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              const Flexible(
                child: Text(
                  'OptiZenqor Socity',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
