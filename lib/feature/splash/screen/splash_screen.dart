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
          final double logoWidth = constraints.maxWidth * 0.72;
          final double logoHeight = constraints.maxHeight * 0.22;

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: logoWidth.clamp(200.0, 360.0),
                height: logoHeight.clamp(84.0, 160.0),
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
