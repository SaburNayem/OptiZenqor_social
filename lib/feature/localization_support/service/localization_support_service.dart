import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class LocalizationSupportService extends FeatureServiceBase {
  LocalizationSupportService({super.apiClient});

  @override
  String get featureName => 'localization_support';

  @override
  Map<String, String> get endpoints => <String, String>{
    'localization_support': ApiEndPoints.localizationSupport,
    'master_data': ApiEndPoints.masterData,
    'app_config': ApiEndPoints.appConfig,
  };
}
