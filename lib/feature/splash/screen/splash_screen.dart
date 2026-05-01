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
      backgroundColor: AppColors.splashBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.white, width: 3),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Icon(
                    Icons
                        .handshake_rounded, // Best fit for the logo shape in icons
                    color: AppColors.black,
                    size: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'OPTIZENQOR SOCIETY',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
