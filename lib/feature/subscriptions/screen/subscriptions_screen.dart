import 'package:flutter/material.dart';

import '../controller/subscriptions_controller.dart';

class SubscriptionsScreen extends StatelessWidget {
  SubscriptionsScreen({super.key});

  final SubscriptionsController _controller = SubscriptionsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: _controller.plans
              .map(
                (plan) => Card(
                  child: ListTile(
                    title: Text(plan.name),
                    subtitle: Text(
                      '\$${plan.price.toStringAsFixed(2)} / month',
                    ),
                    trailing: FilledButton(
                      onPressed: () => _controller.upgradeOrDowngrade(plan.id),
                      child: Text(
                        _controller.activePlanId == plan.id
                            ? 'Active'
                            : 'Select',
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
