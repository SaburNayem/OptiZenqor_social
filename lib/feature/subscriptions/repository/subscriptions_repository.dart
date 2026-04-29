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

  Future<List<SubscriptionPlanModel>> plans() async {
    for (final String key in <String>[
      'premium_plans',
      'plans',
      'monetization_overview',
      'subscriptions',
      'monetization_subscriptions',
    ]) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }
        final List<Map<String, dynamic>> items = _readPlanItems(response.data);
        if (items.isNotEmpty) {
          return items
              .map(SubscriptionPlanModel.fromApiJson)
              .where((SubscriptionPlanModel item) => item.id.isNotEmpty)
              .toList(growable: false);
        }
      } catch (_) {}
    }
    return const <SubscriptionPlanModel>[];
  }

  Future<String?> activePlanId() async {
    try {
      for (final String key in <String>[
        'subscriptions',
        'monetization_subscriptions',
        'monetization_overview',
      ]) {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }
        final String remotePlanId = _readActivePlanId(response.data);
        if (remotePlanId.isNotEmpty) {
          await _preferences.write(
            StorageKeys.activeSubscriptionPlan,
            remotePlanId,
          );
          return remotePlanId;
        }
      }
    } catch (_) {}

    return _preferences.read<String>(StorageKeys.activeSubscriptionPlan);
  }

  Future<void> saveActivePlanId(String planId) async {
    await _preferences.write(StorageKeys.activeSubscriptionPlan, planId);
  }

  String get billingEndpoint => ApiEndPoints.subscriptions;

  List<Map<String, dynamic>> _readPlanItems(Map<String, dynamic> response) {
    final List<Map<String, dynamic>> directItems = ApiPayloadReader.readMapList(
      response,
      preferredKeys: const <String>['plans', 'subscriptions', 'items', 'data'],
    );
    if (directItems.isNotEmpty) {
      final bool looksLikePlanList = directItems.any(
        (Map<String, dynamic> item) =>
            ApiPayloadReader.readString(
              item['billingInterval'] ?? item['code'] ?? item['name'],
            ).isNotEmpty,
      );
      if (looksLikePlanList) {
        return directItems;
      }
    }

    final Map<String, dynamic>? data = ApiPayloadReader.readMap(response['data']);
    final List<Map<String, dynamic>> overviewPlans =
        ApiPayloadReader.readMapListFromAny(data?['plans']);
    if (overviewPlans.isNotEmpty) {
      return overviewPlans;
    }

    final List<Map<String, dynamic>> subscriptions =
        ApiPayloadReader.readMapListFromAny(
      data?['subscriptions'] ?? response['subscriptions'],
    );
    return subscriptions
        .map(
          (Map<String, dynamic> item) =>
              ApiPayloadReader.readMap(item['plan']) ?? const <String, dynamic>{},
        )
        .where((Map<String, dynamic> item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String _readActivePlanId(Map<String, dynamic> response) {
    final Map<String, dynamic>? data = ApiPayloadReader.readMap(response['data']);
    final String direct = ApiPayloadReader.readString(
      response['activePlanId'] ?? data?['activePlanId'],
    );
    if (direct.isNotEmpty) {
      return direct;
    }

    final Map<String, dynamic>? activePlan = ApiPayloadReader.readMap(
      data?['activePlan'] ?? response['activePlan'],
    );
    final String activePlanId = ApiPayloadReader.readString(
      activePlan?['id'] ?? activePlan?['planId'],
    );
    if (activePlanId.isNotEmpty) {
      return activePlanId;
    }

    final List<Map<String, dynamic>> subscriptions =
        ApiPayloadReader.readMapListFromAny(
      data?['subscriptions'] ?? response['subscriptions'] ?? data ?? response,
    );
    for (final Map<String, dynamic> item in subscriptions) {
      final String status = ApiPayloadReader.readString(item['status'])
          .toLowerCase();
      if (status == 'active' || status == 'trialing' || status == 'current') {
        return ApiPayloadReader.readString(
          item['planId'] ?? ApiPayloadReader.readMap(item['plan'])?['id'],
        );
      }
    }
    return '';
  }
}
