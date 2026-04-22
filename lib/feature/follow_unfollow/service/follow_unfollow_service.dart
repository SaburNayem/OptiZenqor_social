import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class FollowUnfollowService extends FeatureServiceBase {
  FollowUnfollowService({super.apiClient});

  @override
  String get featureName => 'follow_unfollow';

  @override
  Map<String, String> get endpoints => <String, String>{
    'users': ApiEndPoints.users,
    'user': ApiEndPoints.userById(':id'),
    'follow': ApiEndPoints.userFollow(':id'),
  };
}
