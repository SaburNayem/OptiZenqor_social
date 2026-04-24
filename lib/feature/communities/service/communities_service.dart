import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class CommunitiesService extends FeatureServiceBase {
  CommunitiesService({super.apiClient});

  @override
  String get featureName => 'communities';

  @override
  Map<String, String> get endpoints => <String, String>{
    'communities': ApiEndPoints.communities,
  };
}
