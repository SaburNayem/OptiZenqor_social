import 'package:flutter/material.dart';

import '../../splash/controller/splash_controller.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E1726), Color(0xFF1D4ED8), Color(0xFF0EA5A4)],
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.4, end: 1.0),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 64),
                SizedBox(height: 14),
                Text(
                  'OptiZenqor Social',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'People. Media. Communities. Growth.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
