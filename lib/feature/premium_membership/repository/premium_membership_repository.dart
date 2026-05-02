import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../../subscriptions/repository/subscriptions_repository.dart';
import '../model/premium_plan_model.dart';
import '../service/premium_membership_service.dart';

class PremiumMembershipRepository {
  PremiumMembershipRepository({
    PremiumMembershipService? service,
    SubscriptionsRepository? subscriptionsRepository,
  }) : _service = service ?? PremiumMembershipService(),
       _subscriptionsRepository =
           subscriptionsRepository ?? SubscriptionsRepository();

  final PremiumMembershipService _service;
  final SubscriptionsRepository _subscriptionsRepository;

  Future<List<PremiumPlanModel>> loadPlans() async {
    for (final String key in <String>[
      'premium_membership',
      'premium_plans',
      'plans',
      'premium',
    ]) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }
        final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['plans', 'items', 'results', 'data'],
        );
        if (items.isNotEmpty) {
          return items
              .map(PremiumPlanModel.fromApiJson)
              .where((PremiumPlanModel item) => item.id.isNotEmpty)
              .toList(growable: false);
        }
      } catch (_) {}
    }

    return const <PremiumPlanModel>[];
  }

  Future<String?> loadActivePlanId() => _subscriptionsRepository.activePlanId();

  Future<void> changePlan(String planId) =>
      _subscriptionsRepository.saveActivePlanId(planId);
}
