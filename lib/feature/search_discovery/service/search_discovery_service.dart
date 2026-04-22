import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class SearchDiscoveryService extends FeatureServiceBase {
  SearchDiscoveryService({super.apiClient});

  @override
  String get featureName => 'search_discovery';

  @override
  Map<String, String> get endpoints => <String, String>{
    'search': ApiEndPoints.search,
    'hashtags': ApiEndPoints.hashtags,
    'trending': ApiEndPoints.trending,
  };
}
