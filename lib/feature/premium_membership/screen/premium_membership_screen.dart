import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../controller/premium_membership_controller.dart';

class PremiumMembershipScreen extends StatelessWidget {
  PremiumMembershipScreen({super.key});

  final PremiumMembershipController _controller = PremiumMembershipController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Premium Membership')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Creator supporter levels')),
                      Chip(label: Text('Seller loyalty rewards')),
                      Chip(label: Text('Referral progress tracking')),
                      Chip(label: Text('Membership perk history')),
                    ],
                  ),
                ),
              ),
              ..._controller.plans.map(
                (plan) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            if (_controller.selectedPlanName == plan.name)
                              const Chip(label: Text('Selected')),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(plan.price),
                        const SizedBox(height: 10),
                        ...plan.features.map((feature) => Text('• $feature')),
                        const SizedBox(height: 14),
                        AppButton(
                          label: 'Choose ${plan.name}',
                          onPressed: () {
                            _controller.choosePlan(plan.name);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(content: Text('${plan.name} selected')),
                              );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
