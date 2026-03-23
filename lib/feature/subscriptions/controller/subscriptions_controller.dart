import 'package:flutter/foundation.dart';

import '../model/subscription_plan_model.dart';
import '../repository/subscriptions_repository.dart';

class SubscriptionsController extends ChangeNotifier {
  SubscriptionsController({SubscriptionsRepository? repository})
      : _repository = repository ?? SubscriptionsRepository() {
    plans = _repository.plans();
    activePlanId = plans.isNotEmpty ? plans.first.id : null;
  }

  final SubscriptionsRepository _repository;
  List<SubscriptionPlanModel> plans = <SubscriptionPlanModel>[];
  String? activePlanId;

  void upgradeOrDowngrade(String planId) {
    activePlanId = planId;
    notifyListeners();
  }
}
