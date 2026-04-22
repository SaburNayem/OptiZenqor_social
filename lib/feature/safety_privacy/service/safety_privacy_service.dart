import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class SafetyPrivacyService extends FeatureServiceBase {
  SafetyPrivacyService({super.apiClient});

  @override
  String get featureName => 'safety_privacy';

  @override
  Map<String, String> get endpoints => <String, String>{
    'safety_config': ApiEndPoints.safetyConfig,
    'security_state': ApiEndPoints.securityState,
    'legal_consents': ApiEndPoints.legalConsents,
  };
}
