import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class RecruiterProfileService extends FeatureServiceBase {
  RecruiterProfileService({super.apiClient});

  @override
  String get featureName => 'recruiter_profile';

  @override
  Map<String, String> get endpoints => <String, String>{
    'recruiter_profile': ApiEndPoints.recruiterProfile,
    'professional_profiles': ApiEndPoints.professionalProfiles,
    'user_profile': ApiEndPoints.profileById(':id'),
  };
}
