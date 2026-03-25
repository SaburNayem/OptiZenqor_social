import 'package:flutter/foundation.dart';

import '../model/subscription_plan_model.dart';
import '../repository/subscriptions_repository.dart';

class SubscriptionsController extends ChangeNotifier {
  SubscriptionsController({SubscriptionsRepository? repository})
      : _repository = repository ?? SubscriptionsRepository();

  final SubscriptionsRepository _repository;
  List<SubscriptionPlanModel> plans = <SubscriptionPlanModel>[];
  String? activePlanId;
  bool isLoading = true;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    plans = await _repository.plans();
    activePlanId =
        await _repository.activePlanId() ?? (plans.isNotEmpty ? plans.first.id : null);
    isLoading = false;
    notifyListeners();
  }

  Future<void> upgradeOrDowngrade(String planId) async {
    activePlanId = planId;
    await _repository.saveActivePlanId(planId);
    notifyListeners();
  }
}
