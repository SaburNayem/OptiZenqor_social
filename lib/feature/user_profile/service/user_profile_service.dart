import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class UserProfileService extends FeatureServiceBase {
  UserProfileService({super.apiClient});

  @override
  String get featureName => 'user_profile';

  @override
  Map<String, String> get endpoints => <String, String>{
    'profile': ApiEndPoints.profile,
    'profile_by_id': ApiEndPoints.profileById(':id'),
    'user_profile': ApiEndPoints.userProfile,
    'user_profile_by_id': ApiEndPoints.userProfileById(':id'),
    'edit_profile': ApiEndPoints.userProfileEdit,
    'users': ApiEndPoints.users,
    'user': ApiEndPoints.userById(':id'),
    'me': ApiEndPoints.authMe,
  };
}
