import 'package:flutter/foundation.dart';

import '../model/premium_plan_model.dart';

class PremiumMembershipController extends ChangeNotifier {
  final List<PremiumPlanModel> plans = const [
    PremiumPlanModel(
      name: 'Free',
      price: '\$0',
      features: ['Standard feed', 'Basic messaging', 'Public communities'],
    ),
    PremiumPlanModel(
      name: 'Premium',
      price: '\$9.99 / month',
      features: ['Priority reach', 'Advanced analytics', 'Premium badge'],
    ),
  ];
}
