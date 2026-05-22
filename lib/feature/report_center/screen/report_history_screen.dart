import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../controller/report_center_controller.dart';
import '../model/report_item_model.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  late final ReportCenterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReportCenterController()..load();
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
      builder: (BuildContext context, _) {
        final List<ReportItemModel> reports = _controller.visibleHistory;
        return Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: AppBar(
            title: const Text('Report History'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Refresh',
                onPressed: _controller.refresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: <Widget>[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (_controller.state.isLoading)
                          const LinearProgressIndicator(minHeight: 2),
                        _HistoryHeader(
                          count: reports.length,
                          activeFilter: _controller.historyFilter,
                          onFilterChanged: _controller.setHistoryFilter,
                        ),
                        const SizedBox(height: 12),
                        if (_controller.state.hasError)
                          _HistoryMessage(
                            icon: Icons.info_outline_rounded,
                            title: 'Unable to load report history',
                            message:
                                _controller.state.errorMessage ??
                                'Pull down to try again.',
                          )
                        else if (reports.isEmpty)
                          const _HistoryMessage(
                            icon: Icons.fact_check_outlined,
                            title: 'No reports here yet',
                            message:
                                'Reports you submit from posts, profiles, jobs, or marketplace listings will appear here.',
                          )
                        else
                          ...reports.map(_ReportHistoryTile.new),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({
    required this.count,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final int count;
  final ReportHistoryFilter activeFilter;
  final ValueChanged<ReportHistoryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Your reports',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: <Widget>[
              _HistoryFilterChip(
                label: 'All',
                selected: activeFilter == ReportHistoryFilter.all,
                onTap: () => onFilterChanged(ReportHistoryFilter.all),
              ),
              _HistoryFilterChip(
                label: 'Open',
                selected: activeFilter == ReportHistoryFilter.open,
                onTap: () => onFilterChanged(ReportHistoryFilter.open),
              ),
              _HistoryFilterChip(
                label: 'Closed',
                selected: activeFilter == ReportHistoryFilter.closed,
                onTap: () => onFilterChanged(ReportHistoryFilter.closed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _ReportHistoryTile extends StatelessWidget {
  const _ReportHistoryTile(this.item);

  final ReportItemModel item;

  @override
  Widget build(BuildContext context) {
    final DateTime? createdAt = item.createdAt?.toLocal();
    final String time = createdAt == null
        ? ''
        : DateFormat('MMM d, h:mm a').format(createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  item.displayTitle,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(label: item.statusLabel, status: item.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.targetLabel.isEmpty
                ? '${item.targetTypeLabel} ${item.targetId}'
                : item.targetLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (item.targetSummary?.trim().isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                item.targetSummary!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.grey600, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              _SeverityBadge(severity: item.severity),
              _MiniBadge(label: item.targetTypeLabel),
              if (time.isNotEmpty) _MiniBadge(label: time),
            ],
          ),
          if (item.statusDescription.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              item.statusDescription,
              style: const TextStyle(color: AppColors.grey600, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.status});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    final String value = normalizeReportKey(status);
    final bool open = value != 'resolved' && value != 'rejected';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: open ? AppColors.primary50 : AppColors.grey200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: open ? AppColors.primary800 : AppColors.grey700,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final String severity;

  @override
  Widget build(BuildContext context) {
    final String value = normalizeReportKey(severity);
    final Color color = switch (value) {
      'critical' => AppColors.hexFFE53935,
      'high' => AppColors.hexFFFB8C00,
      'medium' => AppColors.primary800,
      _ => AppColors.grey700,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value.isEmpty ? 'medium' : value,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.grey700,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.grey600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
