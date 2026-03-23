import 'package:flutter/material.dart';

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
          body: ListView.builder(
            itemCount: _controller.drafts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Card(
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Content calendar placeholder')),
                        Chip(label: Text('Scheduled content calendar')),
                        Chip(label: Text('Creator reminder system')),
                        Chip(label: Text('Event reminder management')),
                        Chip(label: Text('Task/todo for creators/sellers/recruiters')),
                        Chip(label: Text('Shared collections placeholder')),
                        Chip(label: Text('Collaborative post placeholder')),
                      ],
                    ),
                  ),
                );
              }
              final item = _controller.drafts[index - 1];
              return Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(
                    item.scheduledAt == null
                        ? 'Not scheduled'
                        : 'Scheduled: ${item.scheduledAt}',
                  ),
                  trailing: FilledButton(
                    onPressed: () => _controller.scheduleDraft(
                      item.id,
                      DateTime.now().add(const Duration(days: 1)),
                    ),
                    child: const Text('Schedule'),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
