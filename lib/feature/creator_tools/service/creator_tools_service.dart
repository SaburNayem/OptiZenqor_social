import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class CreatorToolsService extends FeatureServiceBase {
  CreatorToolsService({super.apiClient});

  @override
  String get featureName => 'creator_tools';

  @override
  Map<String, String> get endpoints => <String, String>{
    'creator_dashboard': ApiEndPoints.creatorDashboard,
    'monetization_overview': ApiEndPoints.monetizationOverview,
    'monetization_plans': ApiEndPoints.monetizationPlans,
    'upload_manager': ApiEndPoints.uploadManager,
    'drafts': ApiEndPoints.drafts,
    'scheduling': ApiEndPoints.scheduling,
  };
}
