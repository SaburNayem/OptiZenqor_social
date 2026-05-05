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
  static const Duration _debugBootstrapTimeout = Duration(seconds: 2);
  static const Duration _releaseBootstrapTimeout = Duration(seconds: 5);

  Duration get _bootstrapTimeout =>
      kDebugMode ? _debugBootstrapTimeout : _releaseBootstrapTimeout;

  Future<String> resolveInitialRoute() async {
    state = state.copyWith(status: SplashStatus.bootstrapping);
    final Future<bool> onboardingFuture = _safeBool(
      () => _onboardingRepository.isCompleted(),
      fallback: false,
      label: 'onboardingState',
    );
    final Future<bool> sessionFuture = _safeBool(
      () => _authRepository.hasSession(),
      fallback: false,
      label: 'hasSession',
    );
    final List<Object?> bootstrapResults = await Future.wait<Object?>(<Future<Object?>>[
      onboardingFuture,
      sessionFuture,
    ]);
    final bool hasCompletedOnboarding = bootstrapResults[0] as bool;
    final bool hasSession = bootstrapResults[1] as bool;
    bool canShowOnboarding = true;
    if (!hasCompletedOnboarding) {
      canShowOnboarding = await _safeBool(
        () => _onboardingRepository.hasUsableContent(),
        fallback: false,
        label: 'onboardingContent',
      );
    }
    state = state.copyWith(status: SplashStatus.ready);
    return !hasCompletedOnboarding && canShowOnboarding
        ? RouteNames.onboarding
        : hasSession
        ? RouteNames.shell
        : RouteNames.login;
  }

  Future<void> bootstrap(BuildContext context) async {
    final Future<void> splashDelay = Future<void>.delayed(
      kDebugMode
          ? const Duration(milliseconds: 150)
          : const Duration(milliseconds: 450),
    );
    final Future<String> routeFuture = resolveInitialRoute().timeout(
      _bootstrapTimeout,
      onTimeout: () {
        if (kDebugMode) {
          debugPrint(
            '[SplashController] bootstrap timed out after $_bootstrapTimeout',
          );
        }
        return RouteNames.login;
      },
    );
    final List<Object?> bootstrapResults = await Future.wait<Object?>(<Future<Object?>>[
      routeFuture,
      splashDelay,
    ]);
    if (!context.mounted) {
      return;
    }
    final String nextRoute = bootstrapResults[0] as String;
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  Future<bool> _safeBool(
    Future<bool> Function() action, {
    required bool fallback,
    required String label,
  }) async {
    try {
      return await action().timeout(
        _bootstrapTimeout,
        onTimeout: () {
          if (kDebugMode) {
            debugPrint(
              '[SplashController] $label timed out after $_bootstrapTimeout',
            );
          }
          return fallback;
        },
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[SplashController] $label failed: $error');
      }
      return fallback;
    }
  }
}
