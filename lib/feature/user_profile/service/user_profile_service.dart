import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class UserProfileService extends FeatureServiceBase {
  UserProfileService({super.apiClient});

  @override
  String get featureName => 'user_profile';

  @override
  Map<String, String> get endpoints => <String, String>{
    'users': ApiEndPoints.users,
    'user': ApiEndPoints.userById(':id'),
    'me': ApiEndPoints.authMe,
  };
}
