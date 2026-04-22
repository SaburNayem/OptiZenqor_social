import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class HashtagsService extends FeatureServiceBase {
  HashtagsService({super.apiClient});

  @override
  String get featureName => 'hashtags';

  @override
  Map<String, String> get endpoints => <String, String>{
    'hashtags': ApiEndPoints.hashtags,
    'trending': ApiEndPoints.trending,
  };
}
