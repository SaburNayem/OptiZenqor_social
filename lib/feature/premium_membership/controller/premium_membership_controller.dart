import 'package:flutter/foundation.dart';

import '../model/premium_plan_model.dart';

class PremiumMembershipController extends ChangeNotifier {
  String selectedPlanName = 'Premium';

  final List<PremiumPlanModel> plans = const [
    PremiumPlanModel(
      name: 'Free',
      price: '\$0',
      billingLabel: 'Always free',
      description:
          'A simple starting point for browsing, posting, and joining communities.',
      features: [
        'Standard feed distribution',
        'Basic messaging',
        'Public communities access',
      ],
    ),
    PremiumPlanModel(
      name: 'Premium',
      price: '\$9.99',
      billingLabel: 'per month',
      description:
          'Best for creators and professionals who want stronger reach and deeper insights.',
      badge: 'Most popular',
      features: [
        'Priority reach on key posts',
        'Advanced analytics and audience insights',
        'Premium badge on your profile',
        'Early access to new creator tools',
      ],
    ),
    PremiumPlanModel(
      name: 'Premium Annual',
      price: '\$89.99',
      billingLabel: 'per year',
      description:
          'Lower yearly price with the full premium toolset for creators building consistently.',
      badge: 'Best value',
      savingsLabel: 'Save 25%',
      features: [
        'Everything in Premium',
        'Priority support for billing and account issues',
        'Campaign and referral perk history',
        'Lower yearly cost than monthly billing',
      ],
    ),
  ];

  void choosePlan(String planName) {
    selectedPlanName = planName;
    notifyListeners();
  }
}
