import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class NotificationsService extends FeatureServiceBase {
  NotificationsService({super.apiClient});

  @override
  String get featureName => 'notifications';

  @override
  Map<String, String> get endpoints => <String, String>{
    'notifications': ApiEndPoints.notifications,
    'inbox': ApiEndPoints.notificationsInbox,
    'campaigns': ApiEndPoints.notificationsCampaigns,
    'preferences': ApiEndPoints.notificationsPreferences,
  };
}
