import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class HomeFeedService extends FeatureServiceBase {
  HomeFeedService({super.apiClient});

  @override
  String get featureName => 'home_feed';

  @override
  Map<String, String> get endpoints => <String, String>{
    'feed': ApiEndPoints.feed,
    'posts': ApiEndPoints.posts,
    'stories': ApiEndPoints.stories,
    'reels': ApiEndPoints.reels,
  };
}
