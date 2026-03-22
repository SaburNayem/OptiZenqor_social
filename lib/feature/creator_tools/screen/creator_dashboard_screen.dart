import 'package:flutter/material.dart';

import '../controller/creator_dashboard_controller.dart';

class CreatorDashboardScreen extends StatelessWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CreatorDashboardController();

    return Scaffold(
      appBar: AppBar(title: const Text('Creator Dashboard')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.metrics.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
        ),
        itemBuilder: (_, index) {
          final metric = controller.metrics[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(metric.label),
                  const Spacer(),
                  Text(
                    metric.value,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
