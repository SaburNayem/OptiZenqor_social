import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class MaintenanceModeService extends FeatureServiceBase {
  MaintenanceModeService({super.apiClient});

  @override
  String get featureName => 'maintenance_mode';

  @override
  Map<String, String> get endpoints => <String, String>{
    'maintenance_mode': ApiEndPoints.maintenanceMode,
    'retry': ApiEndPoints.maintenanceModeRetry,
    'app_config': ApiEndPoints.appConfig,
  };
}
