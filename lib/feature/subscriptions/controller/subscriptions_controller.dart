import 'package:flutter/foundation.dart';

import '../model/subscription_plan_model.dart';
import '../repository/subscriptionsimport '../repository/subscriptionsimport '../repository/subscriptionsimport '../criptionimport '../repository/subscriptionsimport '../repository/subscriptionsimport '../repository/subscriptionsimport '../criptionimport '../repository/subscriptionsimport '../repository/subscriptionsimport '../repository/subscriptionsimport '../criptionimport '../repo) import '../repository/subscriptionsimport '../repository/subscriptionsimport '../repository/subscriptionsimport '../criptionimport '../repository/subscriptionsimport '../repository/subscriptionsimport '../repository/subscriptionsimport '../criptionimport '../repository/subscriptionsimport '../repository/subscriptionsimport '../repository/subscriptionsimport '../criptionimport '../repo) import '../repository/subscriptionsimport '../repository/subscriptionsimntroller _controller = SubscriptionsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => ListView(
          padding: const EdgeInsets.all(16),
          children: _controller.plans.map((plan) => Card(child: ListTile(title: Text(plan.name), subtitle: Text('\$${plan.price.toStringAsFixed(2)} / month'), trailing: FilledButton(onPressed: () => _controller.upgradeOrDowngrade(plan.id), child: Text(_controller.activePlanId == plan.id ? 'Active' : 'Select'))))).toList(),
        ),
      ),
    );
  }
}
