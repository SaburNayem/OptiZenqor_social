import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class JobsNetworkingService extends FeatureServiceBase {
  JobsNetworkingService({super.apiClient});

  @override
  String get featureName => 'jobs_networking';

  @override
  Map<String, String> get endpoints => <String, String>{
    'jobs': ApiEndPoints.jobs,
    'job': ApiEndPoints.jobById(':id'),
    'apply': ApiEndPoints.jobApply(':id'),
    'save': ApiEndPoints.saveJob(':id'),
    'withdraw_application': ApiEndPoints.withdrawJobApplication(':id'),
    'job_alert': ApiEndPoints.jobAlertById(':id'),
    'follow_company': ApiEndPoints.followJobCompany(':id'),
    'professional_profiles': ApiEndPoints.professionalProfiles,
  };
}
