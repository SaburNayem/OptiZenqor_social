import 'package:flutter/material.dart';

import '../controller/creator_dashboard_controller.dart';
import '../model/creator_metric_model.dart';

class CreatorDashboardScreen extends StatelessWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CreatorDashboardController();

    return Scaffold(
      appBar: AppBar(title: const Text('Creator Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _overviewCard(context, controller),
          const SizedBox(height: 16),
          _sectionTitle(context, 'Performance overview'),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: controller.metrics.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.08,
            ),
            itemBuilder: (context, index) {
              final metric = controller.metrics[index];
              return _metricCard(context, metric);
            },
          ),
          const SizedBox(height: 20),
          _sectionTitle(context, 'Top content insights'),
          const SizedBox(height: 12),
          ...controller.topPerformingContent.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _contentInsightCard(context, item),
            ),
          ),
          const SizedBox(height: 8),
          _sectionTitle(context, 'Audience insights'),
          const SizedBox(height: 12),
          ...controller.audienceInsights.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _audienceInsightTile(context, item),
            ),
          ),
          const SizedBox(height: 8),
          _sectionTitle(context, 'Creator workspace'),
          const SizedBox(height: 12),
          _libraryCard(context, controller),
          const SizedBox(height: 20),
          _sectionTitle(context, 'Action items'),
          const SizedBox(height: 12),
          ...controller.actionItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _actionCard(context, item),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _overviewCard(
    BuildContext context,
    CreatorDashboardController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF202B52), Color(0xFF3A4E8F)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Creator performance snapshot',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your content is gaining stronger non-follower reach, with reels and carousel posts driving the biggest growth this week.',
            style: TextStyle(color: Colors.white70, height: 1.45),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _overviewStat(
                  context,
                  'Posting cadence',
                  '5 posts this week',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _overviewStat(
                  context,
                  'Brand response rate',
                  '82% replied',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewStat(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(BuildContext context, CreatorMetricModel metric) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: metric.highlightColor.withValues(alpha: 0.14),
            foregroundColor: metric.highlightColor,
            child: Icon(metric.icon),
          ),
          const Spacer(),
          Text(
            metric.value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(metric.label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            metric.delta,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentInsightCard(BuildContext context, CreatorContentInsight item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(label: Text(item.type)),
              const Spacer(),
              Text(
                item.reach,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(item.summary),
          const SizedBox(height: 10),
          Text(
            item.engagementRate,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _audienceInsightTile(
    BuildContext context,
    CreatorAudienceInsight item,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      tileColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(item.label),
      subtitle: Text(item.details),
      trailing: SizedBox(
        width: 120,
        child: Text(
          item.value,
          textAlign: TextAlign.right,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _libraryCard(
    BuildContext context,
    CreatorDashboardController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Creator library and workflow',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Keep your drafts, templates, campaign assets, and collaboration tasks in one place.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.libraryTools
                  .map((item) => Chip(label: Text(item)))
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(BuildContext context, CreatorActionItem item) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(item.icon)),
        title: Text(item.title),
        subtitle: Text(item.subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}
