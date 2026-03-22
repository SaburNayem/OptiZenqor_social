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
            itemCount: _controller.drafts.length,
            itemBuilder: (context, index) {
              final item = _controller.drafts[index];
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
