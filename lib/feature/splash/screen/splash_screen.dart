import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double logoWidth = constraints.maxWidth * 0.68;
          final double logoHeight = constraints.maxHeight * 0.18;

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: logoWidth.clamp(180.0, 320.0),
                    height: logoHeight.clamp(72.0, 140.0),
                    child: SvgPicture.asset(
                      'assets/logo.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'OptiZenqor Socity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
