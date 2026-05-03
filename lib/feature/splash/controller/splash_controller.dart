import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../auth/repository/auth_repository.dart';
import '../../onboarding/repository/onboarding_repository.dart';
import '../../../app_route/route_names.dart';
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
    final Future<bool> onboardingFuture = _onboardingRepository.isCompleted();
    final Future<bool> sessionFuture = _authRepository.hasSession();
    final Future<void> splashDelay = Future<void>.delayed(
      kDebugMode
          ? const Duration(milliseconds: 150)
          : const Duration(milliseconds: 450),
    );
    final List<Object?> bootstrapResults = await Future.wait<Object?>(
      <Future<Object?>>[onboardingFuture, sessionFuture, splashDelay],
    );
    final bool hasCompletedOnboarding = bootstrapResults[0] as bool;
    final bool hasSession = bootstrapResults[1] as bool;
    bool canShowOnboarding = true;
    if (!hasCompletedOnboarding) {
      canShowOnboarding = await _onboardingRepository.hasUsableContent();
    }
    if (!context.mounted) {
      return;
    }
    final nextRoute = !hasCompletedOnboarding && canShowOnboarding
        ? RouteNames.onboarding
        : hasSession
        ? RouteNames.shell
        : RouteNames.login;
    state = state.copyWith(status: SplashStatus.ready);
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }
}
