import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class SubscriptionsService extends FeatureServiceBase {
  SubscriptionsService({super.apiClient});

  @override
  String get featureName => 'subscriptions';

  @override
  Map<String, String> get endpoints => <String, String>{
    'subscriptions': ApiEndPoints.subscriptions,
    'monetization_subscriptions': ApiEndPoints.monetizationSubscriptions,
    'plans': ApiEndPoints.monetizationPlans,
  };
}
