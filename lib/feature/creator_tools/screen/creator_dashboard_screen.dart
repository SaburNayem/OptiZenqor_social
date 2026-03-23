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
        itemCount: controller.metrics.length + 1,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Creator Library'),
                    SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text('All media library')),
                            Chip(label: Text('Reusable drafts')),
                            Chip(label: Text('Saved templates')),
                            Chip(label: Text('Scheduled content calendar')),
                            Chip(label: Text('Bulk content management')),
                            Chip(label: Text('Collaborative boards')),
                            Chip(label: Text('Invite collaborator')),
                            Chip(label: Text('Partnership request')),
                            Chip(label: Text('Campaign invite')),
                            Chip(label: Text('Collaboration inbox')),
                            Chip(label: Text('Reminder system')),
                            Chip(label: Text('Task/todo placeholder')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final metric = controller.metrics[index - 1];
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
