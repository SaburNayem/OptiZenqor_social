import 'package:flutter/material.dart';

import '../controller/drafts_and_scheduling_controller.dart';

class DraftsScreen extends StatelessWidget {
  DraftsScreen({super.key});

  final DraftsAndSchedulingController _controller =
      DraftsAndSchedulingController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final drafts = _controller.drafts
            .where((item) => item.scheduledAt == null)
            .toList();
        return Scaffold(
          appBar: AppBar(title: const Text('My Drafts')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Draft Studio',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Only incomplete unpublished posts and reels appear here.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Drafts ${drafts.length}')),
                        const Chip(label: Text('Reusable drafts')),
                        const Chip(label: Text('Saved templates')),
                        const Chip(label: Text('Bulk management')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (drafts.isEmpty)
                const Card(
                  child: ListTile(
                    title: Text('No drafts yet'),
                    subtitle: Text('Saved post and reel drafts will appear here.'),
                  ),
                ),
              ...drafts.map(
                (item) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(item.type.name.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(item.title),
                    subtitle: Text(
                      'Incomplete ${item.type.name.toUpperCase()} • Audience ${item.audience}'
                      '${item.location == null ? '' : ' • ${item.location}'}',
                    ),
                    trailing: const Chip(label: Text('Incomplete')),
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
