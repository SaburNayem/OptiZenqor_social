import 'package:flutter/material.dart';

import '../controller/drafts_and_scheduling_controller.dart';
import '../model/draft_item_model.dart';

class DraftsScreen extends StatelessWidget {
  DraftsScreen({super.key});

  final DraftsAndSchedulingController _controller =
      DraftsAndSchedulingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final drafts = _controller.drafts
            .where((item) => item.scheduledAt == null)
            .toList();
        final postCount = drafts.where((item) => item.type == PublishType.post).length;
        final reelCount = drafts.where((item) => item.type == PublishType.reel).length;
        final storyCount = drafts.where((item) => item.type == PublishType.story).length;

        return Scaffold(
          appBar: AppBar(title: const Text('My Drafts')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Draft studio',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep unfinished ideas, captions, collaborators, and revisions together before publishing.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.82,
                        ),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _DraftBadge(label: '${drafts.length} total drafts'),
                        _DraftBadge(label: '$postCount posts'),
                        _DraftBadge(label: '$reelCount reels'),
                        _DraftBadge(label: '$storyCount stories'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _StudioMetricCard(
                      title: 'Needs review',
                      value: '${drafts.where((item) => item.editHistory.isNotEmpty).length}',
                      subtitle: 'Drafts with saved revisions',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StudioMetricCard(
                      title: 'Ready assets',
                      value: '${drafts.where((item) => item.altText != null || item.location != null).length}',
                      subtitle: 'Drafts with extra publishing details',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Active draft queue',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Resume editing, review metadata, and check what is still missing before you publish.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              if (drafts.isEmpty)
                _DraftEmptyState(colorScheme: colorScheme)
              else
                ...drafts.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _DraftWorkspaceCard(item: item),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DraftWorkspaceCard extends StatelessWidget {
  const _DraftWorkspaceCard({required this.item});

  final DraftItemModel item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                foregroundColor: colorScheme.primary,
                child: Icon(_iconForType(item.type)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaPill(label: _typeLabel(item.type)),
                        _MetaPill(label: 'Audience ${item.audience}'),
                        if (item.location != null) _MetaPill(label: item.location!),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusTag(
                label: item.editHistory.isEmpty ? 'Saved' : 'In progress',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DraftDetailRow(
            label: 'Collaborators',
            value: item.coAuthors.isEmpty
                ? 'No co-authors added'
                : item.coAuthors.join(', '),
          ),
          const SizedBox(height: 8),
          _DraftDetailRow(
            label: 'Tagged people',
            value: item.taggedPeople.isEmpty
                ? 'No tags yet'
                : item.taggedPeople.join(', '),
          ),
          const SizedBox(height: 8),
          _DraftDetailRow(
            label: 'Accessibility',
            value: item.altText ?? 'Alt text not added yet',
          ),
          const SizedBox(height: 8),
          _DraftDetailRow(
            label: 'Revision history',
            value: item.versionHistory.isEmpty
                ? 'No saved versions'
                : '${item.versionHistory.length} saved versions',
          ),
          if (item.editHistory.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                item.editHistory.last,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('Continue editing'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Preview draft'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _iconForType(PublishType type) {
    switch (type) {
      case PublishType.post:
        return Icons.grid_on_rounded;
      case PublishType.reel:
        return Icons.play_circle_outline_rounded;
      case PublishType.story:
        return Icons.auto_stories_rounded;
    }
  }

  static String _typeLabel(PublishType type) {
    switch (type) {
      case PublishType.post:
        return 'Post draft';
      case PublishType.reel:
        return 'Reel draft';
      case PublishType.story:
        return 'Story draft';
    }
  }
}

class _DraftDetailRow extends StatelessWidget {
  const _DraftDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(height: 1.4, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _DraftEmptyState extends StatelessWidget {
  const _DraftEmptyState({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No drafts yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a post, reel, or story and save it partway through to build your draft workspace here.',
            style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _StudioMetricCard extends StatelessWidget {
  const _StudioMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftBadge extends StatelessWidget {
  const _DraftBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
