import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/shared_preference/app_shared_preferences.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/subscription_plan_model.dart';
import '../service/subscriptions_service.dart';

class SubscriptionsRepository {
  SubscriptionsRepository({
    AppSharedPreferences? preferences,
    SubscriptionsService? service,
  }) : _preferences = preferences ?? AppSharedPreferences(),
       _service = service ?? SubscriptionsService();

  final AppSharedPreferences _preferences;
  final SubscriptionsService _service;

  static const List<SubscriptionPlanModel> _plans = <SubscriptionPlanModel>[
        SubscriptionPlanModel(id: 'free', name: 'Free', price: 0),
        SubscriptionPlanModel(id: 'pro', name: 'Pro', price: 9.99),
        SubscriptionPlanModel(id: 'business', name: 'Business', price: 19.99),
      ];

  Future<List<SubscriptionPlanModel>> plans() async {
    for (final String key in <String>['plans', 'subscriptions', 'monetization_subscriptions']) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }
        final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['plans', 'subscriptions', 'items'],
        );
        if (items.isNotEmpty) {
          return items
              .map(SubscriptionPlanModel.fromApiJson)
              .where((SubscriptionPlanModel item) => item.id.isNotEmpty)
              .toList(growable: false);
        }
      } catch (_) {}
    }

    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _plans;
  }

  Future<String?> activePlanId() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.getEndpoint('subscriptions');
      if (response.isSuccess && response.data['success'] != false) {
        final String remotePlanId = ApiPayloadReader.readString(
          response.data['activePlanId'] ??
              (ApiPayloadReader.readMap(response.data['data'])?['activePlanId']),
        );
        if (remotePlanId.isNotEmpty) {
          await _preferences.write(StorageKeys.activeSubscriptionPlan, remotePlanId);
          return remotePlanId;
        }
      }
    } catch (_) {}

    return _preferences.read<String>(StorageKeys.activeSubscriptionPlan);
  }

  Future<void> saveActivePlanId(String planId) async {
    await _preferences.write(StorageKeys.activeSubscriptionPlan, planId);
    try {
      await _service.postEndpoint(
        'subscriptions',
        payload: <String, dynamic>{'planId': planId},
      );
    } catch (_) {}
  }

  String get billingEndpoint => ApiEndPoints.subscriptions;
}
