import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class AppUpdateFlowService extends FeatureServiceBase {
  AppUpdateFlowService({super.apiClient});

  @override
  String get featureName => 'app_update_flow';

  @override
  Map<String, String> get endpoints => <String, String>{
    'bootstrap': ApiEndPoints.appBootstrap,
    'config': ApiEndPoints.appConfig,
  };
}
