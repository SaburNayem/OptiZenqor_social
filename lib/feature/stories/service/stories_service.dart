import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class StoriesService extends FeatureServiceBase {
  StoriesService({super.apiClient});

  @override
  String get featureName => 'stories';

  @override
  Map<String, String> get endpoints => <String, String>{
    'stories': ApiEndPoints.stories,
  };
}
