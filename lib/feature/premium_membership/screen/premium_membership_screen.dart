import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../controller/premium_membership_controller.dart';

class PremiumMembershipScreen extends StatelessWidget {
  const PremiumMembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PremiumMembershipController();

    return Scaffold(
      appBar: AppBar(title: const Text('Premium Membership')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...controller.plans.map(
            (plan) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(plan.price),
                    const SizedBox(height: 10),
                    ...plan.features.map((feature) => Text('• $feature')),
                    const SizedBox(height: 14),
                    AppButton(label: 'Choose ${plan.name}', onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
