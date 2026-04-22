import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class PersonalizationOnboardingService extends FeatureServiceBase {
  PersonalizationOnboardingService({super.apiClient});

  @override
  String get featureName => 'personalization_onboarding';

  @override
  Map<String, String> get endpoints => <String, String>{
    'personalization_onboarding': ApiEndPoints.personalizationOnboarding,
    'interests': ApiEndPoints.personalizationOnboardingInterests,
    'recommendations': ApiEndPoints.recommendations,
  };
}
