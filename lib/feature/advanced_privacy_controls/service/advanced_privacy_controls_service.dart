import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class AdvancedPrivacyControlsService extends FeatureServiceBase {
  AdvancedPrivacyControlsService({super.apiClient});

  @override
  String get featureName => 'advanced_privacy_controls';

  @override
  Map<String, String> get endpoints => <String, String>{
    'advanced_privacy_controls': ApiEndPoints.advancedPrivacyControls,
    'safety_config': ApiEndPoints.safetyConfig,
    'legal_consents': ApiEndPoints.legalConsents,
    'security_state': ApiEndPoints.securityState,
  };
}
