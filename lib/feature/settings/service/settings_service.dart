import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class SettingsService extends FeatureServiceBase {
  SettingsService({super.apiClient});

  @override
  String get featureName => 'settings';

  @override
  Map<String, String> get endpoints => <String, String>{
    'sections': ApiEndPoints.settingsSections,
    'config': ApiEndPoints.appConfig,
    'security_state': ApiEndPoints.securityState,
  };
}
