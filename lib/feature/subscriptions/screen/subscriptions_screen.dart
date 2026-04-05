import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/subscriptions_controller.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubscriptionsController>(
      create: (_) => SubscriptionsController()..load(),
      child: BlocBuilder<SubscriptionsController, SubscriptionsState>(
        builder: (context, state) {
          final controller = context.read<SubscriptionsController>();
          if (state.isLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Subscriptions')),
              body: const Center(child: AppLoader()),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Subscriptions')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: state.plans
                  .map(
                    (plan) => Card(
                      child: ListTile(
                        title: Text(plan.name),
                        subtitle: Text(
                          '\$${plan.price.toStringAsFixed(2)} / month',
                        ),
                        trailing: FilledButton(
                          onPressed: () =>
                              controller.upgradeOrDowngrade(plan.id),
                          child: Text(
                            state.activePlanId == plan.id ? 'Active' : 'Select',
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
