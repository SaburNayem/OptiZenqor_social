import 'package:flutter/material.dart';

import '../../../core/data/service/analytics_service.dart';
import '../../../app_route/route_names.dart';
import '../model/onboarding_slide_model.dart';
import '../repository/onboarding_repository.dart';

class OnboardingController {
  OnboardingController({
    OnboardingRepository? repository,
    AnalyticsService? analyticsService,
  }) : _repository = repository ?? OnboardingRepository(),
       _analyticsService = analyticsService ?? AnalyticsService();

  final PageController pageController = PageController();
  final OnboardingRepository _repository;
  final AnalyticsService _analyticsService;
  int index = 0;

  Future<List<OnboardingSlideModel>> loadSlides() => _repository.loadSlides();

  void onPageChanged(int value, VoidCallback onChanged) {
    index = value;
    onChanged();
  }

  Future<void> next(
    BuildContext context,
    VoidCallback onChanged, {
    required bool isLast,
  }) async {
    if (isLast) {
      await _finish();
      if (!context.mounted) {
        return;
      }
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

  Future<void> skip(BuildContext context) async {
    await _finish();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(RouteNames.login);
  }

  Future<void> _finish() async {
    await _repository.complete();
    await _analyticsService.onboardingCompleted();
  }

  void dispose() {
    pageController.dispose();
  }
}
