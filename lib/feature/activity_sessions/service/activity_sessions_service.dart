import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class ActivitySessionsService extends FeatureServiceBase {
  ActivitySessionsService({super.apiClient});

  @override
  String get featureName => 'activity_sessions';

  @override
  Map<String, String> get endpoints => <String, String>{
    'activity_sessions': ApiEndPoints.activitySessions,
    'history': ApiEndPoints.activitySessionsHistory,
    'logout_others': ApiEndPoints.activitySessionsLogoutOthers,
    'session': ApiEndPoints.activitySessionById(':id'),
    'security_state': ApiEndPoints.securityState,
    'logout_all': ApiEndPoints.securityLogoutAll,
  };
}
