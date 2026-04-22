import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class ExploreRecommendationService extends FeatureServiceBase {
  ExploreRecommendationService({super.apiClient});

  @override
  String get featureName => 'explore_recommendation';

  @override
  Map<String, String> get endpoints => <String, String>{
    'recommendations': ApiEndPoints.recommendations,
    'hashtags': ApiEndPoints.hashtags,
    'trending': ApiEndPoints.trending,
    'search': ApiEndPoints.search,
  };
}
