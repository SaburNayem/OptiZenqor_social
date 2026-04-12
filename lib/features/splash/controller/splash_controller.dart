import 'package:flutter/material.dart';

import '../../auth/repository/auth_repository.dart';
import '../../onboarding/repository/onboarding_repository.dart';
import '../../../route/route_names.dart';
import '../model/splash_state_model.dart';

class SplashController {
  SplashController({
    AuthRepository? authRepository,
    OnboardingRepository? onboardingRepository,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _onboardingRepository = onboardingRepository ?? OnboardingRepository();

  final AuthRepository _authRepository;
  final OnboardingRepository _onboardingRepository;
  SplashStateModel state = const SplashStateModel();

  Future<void> bootstrap(BuildContext context) async {
    state = state.copyWith(status: SplashStatus.bootstrapping);
    await Future<void>.delayed(const Duration(seconds: 2));
    final hasCompletedOnboarding = await _onboardingRepository.isCompleted();
    final hasSession = await _authRepository.hasSession();
    if (!context.mounted) {
      return;
    }
    final nextRoute = !hasCompletedOnboarding
        ? RouteNames.onboarding
        : hasSession
        ? RouteNames.shell
        : RouteNames.login;
    state = state.copyWith(status: SplashStatus.ready);
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }
}
