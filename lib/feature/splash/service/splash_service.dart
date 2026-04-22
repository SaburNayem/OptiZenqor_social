import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class SplashService extends FeatureServiceBase {
  SplashService({super.apiClient});

  @override
  String get featureName => 'splash';

  @override
  Map<String, String> get endpoints => <String, String>{
    'health': ApiEndPoints.health,
    'bootstrap': ApiEndPoints.appBootstrap,
    'config': ApiEndPoints.appConfig,
    'master_data': ApiEndPoints.masterData,
  };
}
