import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class TrendingService extends FeatureServiceBase {
  TrendingService({super.apiClient});

  @override
  String get featureName => 'trending';

  @override
  Map<String, String> get endpoints => <String, String>{
    'trending': ApiEndPoints.trending,
  };
}
