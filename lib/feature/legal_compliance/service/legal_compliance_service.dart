import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class LegalComplianceService extends FeatureServiceBase {
  LegalComplianceService({super.apiClient});

  @override
  String get featureName => 'legal_compliance';

  @override
  Map<String, String> get endpoints => <String, String>{
    'compliance': ApiEndPoints.legalCompliance,
    'consents': ApiEndPoints.legalConsents,
    'account_deletion': ApiEndPoints.legalAccountDeletion,
    'data_export': ApiEndPoints.legalDataExport,
    'settings_state': ApiEndPoints.settingsState,
  };
}
