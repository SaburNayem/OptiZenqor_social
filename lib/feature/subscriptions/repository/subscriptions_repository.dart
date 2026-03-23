import '../model/subscription_plan_model.dart';

class SubscriptionsRepository {
  List<SubscriptionPlanModel> plans() => const <SubscriptionPlanModel>[
        SubscriptionPlanModel(id: 'free', name: 'Free', price: 0),
        SubscriptionPlanModel(id: 'pro', name: 'Pro', price: 9.99),
        SubscriptionPlanModel(id: 'business', name: 'Business', price: 19.99),
      ];
}
