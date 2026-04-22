import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class OnboardingService extends FeatureServiceBase {
  OnboardingService({super.apiClient});

  @override
  String get featureName => 'onboarding';

  @override
  Map<String, String> get endpoints => <String, String>{
    'slides': ApiEndPoints.onboardingSlides,
    'state': ApiEndPoints.onboardingState,
    'interests': ApiEndPoints.onboardingInterests,
    'complete': ApiEndPoints.onboardingComplete,
  };
}
