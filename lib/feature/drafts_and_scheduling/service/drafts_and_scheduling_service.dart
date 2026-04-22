import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class DraftsAndSchedulingService extends FeatureServiceBase {
  DraftsAndSchedulingService({super.apiClient});

  @override
  String get featureName => 'drafts_and_scheduling';

  @override
  Map<String, String> get endpoints => <String, String>{
    'drafts': ApiEndPoints.drafts,
    'draft': ApiEndPoints.draftById(':id'),
    'scheduling': ApiEndPoints.scheduling,
  };
}
