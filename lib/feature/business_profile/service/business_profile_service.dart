import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class BusinessProfileService extends FeatureServiceBase {
  BusinessProfileService({super.apiClient});

  @override
  String get featureName => 'business_profile';

  @override
  Map<String, String> get endpoints => <String, String>{
    'professional_profiles': ApiEndPoints.professionalProfiles,
    'user_profile': ApiEndPoints.userById(':id'),
  };
}
