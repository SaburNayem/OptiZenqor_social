import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/enums/view_state.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../controller/creator_dashboard_controller.dart';
import '../model/creator_metric_model.dart';

class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  late final CreatorDashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CreatorDashboardController();
    Future<void>.microtask(_controller.load);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Creator Dashboard')),
          body: _buildBody(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_controller.viewState) {
      case ViewState.loading:
      case ViewState.idle:
        return const AppLoader(label: 'Loading creator dashboard...');
      case ViewState.error:
        return ErrorStateView(
          message: _controller.errorMessage.isEmpty
              ? 'Unable to load creator dashboard.'
              : _controller.errorMessage,
          onRetry: _controller.load,
        );
      case ViewState.empty:
        return EmptyStateView(
          title: 'No creator analytics yet',
          message:
              'The backend did not return enough creator performance data for this account yet.',
          actionLabel: 'Retry',
          onAction: _controller.load,
        );
      case ViewState.success:
        final CreatorDashboardPayload payload = _controller.payload!;
        return RefreshIndicator(
          onRefresh: _controller.load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _overviewCard(context, payload),
              const SizedBox(height: 16),
              _sectionTitle(context, 'Live performance metrics'),
              const SizedBox(height: 12),
              GridView.builder(
                itemCount: payload.metrics.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.08,
                ),
                itemBuilder: (context, index) {
                  final CreatorMetricModel metric = payload.metrics[index];
                  return _metricCard(context, metric);
                },
              ),
              const SizedBox(height: 20),
              _sectionTitle(context, 'Creator totals'),
              const SizedBox(height: 12),
              ...payload.totals.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _summaryTile(context, item),
                ),
              ),
              const SizedBox(height: 8),
              _sectionTitle(context, 'Account details'),
              const SizedBox(height: 12),
              ...payload.detailItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _summaryTile(context, item),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _overviewCard(BuildContext context, CreatorDashboardPayload payload) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.hexFF202B52, AppColors.hexFF3A4E8F],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            payload.creatorName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${payload.creatorUsername} • ${payload.creatorRole}',
            style: const TextStyle(color: AppColors.white70, height: 1.45),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _overviewStat(
                  context,
                  payload.totals.isNotEmpty
                      ? payload.totals.first.label
                      : 'Posts',
                  payload.totals.isNotEmpty ? payload.totals.first.value : '0',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _overviewStat(
                  context,
                  payload.metrics.isNotEmpty
                      ? payload.metrics.first.label
                      : 'Metric',
                  payload.metrics.isNotEmpty
                      ? payload.metrics.first.value
                      : '0',
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
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.white,
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

  Widget _summaryTile(BuildContext context, CreatorSummaryItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      tileColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(item.label),
      trailing: Text(
        item.value,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
