import 'package:flutter/material.dart';

import '../../../route/route_names.dart';
import '../controller/drafts_and_scheduling_controller.dart';

class DraftsAndSchedulingScreen extends StatelessWidget {
  DraftsAndSchedulingScreen({super.key});

  final DraftsAndSchedulingController _controller =
      DraftsAndSchedulingController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Drafts & Scheduling')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.tertiaryContainer,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publishing Workspace',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drafts and scheduling are now separate so each workflow is cleaner and easier to manage.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed(RouteNames.drafts),
                            icon: const Icon(Icons.drafts_outlined),
                            label: const Text('Open Drafts'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => Navigator.of(context).pushNamed(RouteNames.scheduling),
                            icon: const Icon(Icons.schedule_outlined),
                            label: const Text('Open Scheduling'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.drafts_rounded),
                  title: const Text('Drafts'),
                  subtitle: Text(
                    '${_controller.drafts.where((item) => item.scheduledAt == null).length} unscheduled items',
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text('Scheduling'),
                  subtitle: Text(
                    '${_controller.drafts.where((item) => item.scheduledAt != null).length} scheduled items',
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
