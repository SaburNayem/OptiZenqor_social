import 'package:flutter/material.dart';

import '../controller/drafts_and_scheduling_controller.dart';

class SchedulingScreen extends StatelessWidget {
  SchedulingScreen({super.key});

  final DraftsAndSchedulingController _controller =
      DraftsAndSchedulingController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scheduled = _controller.drafts
            .where((item) => item.scheduledAt != null)
            .toList();
        return Scaffold(
          appBar: AppBar(title: const Text('Scheduling')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publishing Calendar',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Posts and reels you already created and scheduled for upload.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Scheduled ${scheduled.length}')),
                        const Chip(label: Text('Content calendar')),
                        const Chip(label: Text('Creator reminders')),
                        const Chip(label: Text('Todo planner')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (scheduled.isEmpty)
                const Card(
                  child: ListTile(
                    title: Text('Nothing scheduled yet'),
                    subtitle: Text('Scheduled posts and reels will appear here.'),
                  ),
                ),
              ...scheduled.map(
                (item) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.schedule_rounded),
                    title: Text(item.title),
                    subtitle: Text(
                      'Scheduled upload: ${item.scheduledAt}\n'
                      'Created by you • Audience ${item.audience}',
                    ),
                    isThreeLine: true,
                    trailing: const Chip(label: Text('Queued')),
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
