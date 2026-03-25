import 'package:flutter/material.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/subscriptions_controller.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final SubscriptionsController _controller = SubscriptionsController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          if (_controller.isLoading) {
            return const Center(child: AppLoader());
          }

          return ListView(
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
          );
        },
      ),
    );
  }
}
