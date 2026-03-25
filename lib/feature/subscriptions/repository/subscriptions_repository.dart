import '../../../core/constant/storage_keys.dart';
import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/shared_preference/app_shared_preferences.dart';
import '../model/subscription_plan_model.dart';

class SubscriptionsRepository {
  SubscriptionsRepository({AppSharedPreferences? preferences})
      : _preferences = preferences ?? AppSharedPreferences();

  final AppSharedPreferences _preferences;

  static const List<SubscriptionPlanModel> _plans = <SubscriptionPlanModel>[
        SubscriptionPlanModel(id: 'free', name: 'Free', price: 0),
        SubscriptionPlanModel(id: 'pro', name: 'Pro', price: 9.99),
        SubscriptionPlanModel(id: 'business', name: 'Business', price: 19.99),
      ];

  Future<List<SubscriptionPlanModel>> plans() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _plans;
  }

  Future<String?> activePlanId() {
    return _preferences.read<String>(StorageKeys.activeSubscriptionPlan);
  }

  Future<void> saveActivePlanId(String planId) {
    return _preferences.write(StorageKeys.activeSubscriptionPlan, planId);
  }

  String get billingEndpoint => ApiEndPoints.subscriptions;
}
