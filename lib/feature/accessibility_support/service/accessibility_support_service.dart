import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class AccessibilitySupportService extends FeatureServiceBase {
  AccessibilitySupportService({super.apiClient});

  @override
  String get featureName => 'accessibility_support';

  @override
  Map<String, String> get endpoints => <String, String>{
    'accessibility_support': ApiEndPoints.accessibilitySupport,
    'settings_state': ApiEndPoints.settingsState,
  };
}
