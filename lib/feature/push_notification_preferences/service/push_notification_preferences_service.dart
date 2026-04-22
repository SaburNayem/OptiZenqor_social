import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class PushNotificationPreferencesService extends FeatureServiceBase {
  PushNotificationPreferencesService({super.apiClient});

  @override
  String get featureName => 'push_notification_preferences';

  @override
  Map<String, String> get endpoints => <String, String>{
    'preferences': ApiEndPoints.notificationPreferences,
  };
}
