import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_get.dart';
import '../controller/report_center_controller.dart';
import '../model/report_item_model.dart';

class ReportCenterScreen extends StatefulWidget {
  const ReportCenterScreen({super.key, this.arguments});

  final Object? arguments;

  @override
  State<ReportCenterScreen> createState() => _ReportCenterScreenState();
}

class _ReportCenterScreenState extends State<ReportCenterScreen> {
  late final ReportCenterController _controller;
  late final TextEditingController _targetIdController;
  late final TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    final ReportTargetDraft initialTarget = ReportTargetDraft.fromArguments(
      widget.arguments,
    );
    _controller = ReportCenterController(
      initialTarget: initialTarget.hasTarget ? initialTarget : null,
    );
    _targetIdController = TextEditingController(text: initialTarget.targetId)
      ..addListener(() => _controller.updateTargetId(_targetIdController.text));
    _detailsController = TextEditingController()
      ..addListener(() => _controller.updateDetails(_detailsController.text));
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _targetIdController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: AppBar(
            title: const Text('Report Center'),
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
                        _buildHeader(context),
                        const SizedBox(height: 12),
                        if (_controller.state.isLoading)
                          const LinearProgressIndicator(minHeight: 2),
                        if (_controller.state.hasError)
                          _buildErrorPanel(context),
                        _buildComposer(context),
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

  Widget _buildHeader(BuildContext context) {
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
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Help keep the community safe',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tell moderation what happened with the selected item.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPanel(BuildContext context) {
    final String message =
        _controller.state.errorMessage ?? 'Unable to load reports.';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.hexFFFFF3E0,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.hexFFFFAB91),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.info_outline_rounded, color: AppColors.primary800),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
            TextButton(
              onPressed: _controller.refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
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
          Text(
            'New report',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'This goes to moderation with the target, reason, and details.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: 16),
          if (!_controller.hasPrefilledTarget) ...<Widget>[
            _SectionLabel(
              icon: Icons.category_outlined,
              label: 'What are you reporting?',
            ),
            const SizedBox(height: 8),
            _buildTargetChoices(context),
            const SizedBox(height: 16),
          ],
          _SectionLabel(icon: Icons.link_rounded, label: 'Reported item'),
          const SizedBox(height: 8),
          _buildTargetIdentity(context),
          const SizedBox(height: 16),
          _SectionLabel(
            icon: Icons.flag_outlined,
            label: 'Why are you reporting it?',
          ),
          const SizedBox(height: 8),
          _buildReasonChoices(context),
          const SizedBox(height: 16),
          TextField(
            controller: _detailsController,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Add details',
              hintText: 'Share context that helps moderators review this.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          _buildSubmitArea(context),
        ],
      ),
    );
  }

  Widget _buildTargetChoices(BuildContext context) {
    if (_controller.targetOptions.isEmpty) {
      return const _EmptyPanel(
        icon: Icons.pending_outlined,
        title: 'Report types are loading',
        message: 'Please wait a moment.',
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool twoColumns = constraints.maxWidth >= 560;
        final double itemWidth = twoColumns
            ? (constraints.maxWidth - 8) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _controller.targetOptions
              .map((ReportTargetOptionModel option) {
                final bool selected =
                    _controller.selectedTargetType?.key == option.key;
                return SizedBox(
                  width: itemWidth,
                  child: _TargetChoiceTile(
                    option: option,
                    selected: selected,
                    icon: _targetIcon(option.key),
                    onTap: () => _controller.selectTargetType(option),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildTargetIdentity(BuildContext context) {
    final String targetType = _controller.selectedTargetType?.label ?? 'Target';
    if (_controller.hasPrefilledTarget) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary100),
        ),
        child: Row(
          children: <Widget>[
            if (_controller.targetPreviewImageUrl.trim().isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _controller.targetPreviewImageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 10),
            ] else ...[
              Icon(
                _targetIcon(_controller.selectedTargetType?.key ?? ''),
                color: AppColors.primary800,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _controller.targetLabel.trim().isEmpty
                        ? targetType
                        : _controller.targetLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  if (_controller.targetSubtitle.trim().isNotEmpty)
                    Text(
                      _controller.targetSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (_controller.targetLabel.trim().isNotEmpty ||
            _controller.targetSubtitle.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary100),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    _targetIcon(_controller.selectedTargetType?.key ?? ''),
                    color: AppColors.primary800,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _controller.targetLabel.trim().isEmpty
                              ? targetType
                              : _controller.targetLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        if (_controller.targetSubtitle.trim().isNotEmpty)
                          Text(
                            _controller.targetSubtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
            ),
          ),
        TextField(
          controller: _targetIdController,
          decoration: InputDecoration(
            labelText: '$targetType ID',
            hintText: 'Paste the ID or open report from the item menu',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.tag_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonChoices(BuildContext context) {
    final List<ReportReasonOptionModel> reasons = _controller.visibleReasons;
    if (reasons.isEmpty) {
      return const _EmptyPanel(
        icon: Icons.flag_outlined,
        title: 'Choose a report type first',
        message: 'Reasons will match the selected section.',
      );
    }

    return Column(
      children: reasons
          .map((ReportReasonOptionModel reason) {
            final bool selected = _controller.selectedReason?.key == reason.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _controller.selectReason(reason),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary50 : AppColors.grey50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary500
                          : AppColors.grey200,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: selected
                            ? AppColors.primary800
                            : AppColors.grey600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    reason.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                _SeverityBadge(severity: reason.severity),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              reason.description,
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
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }

  Widget _buildSubmitArea(BuildContext context) {
    final String? message = _controller.submitMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FilledButton.icon(
          onPressed: _controller.canSubmit ? _submitReport : null,
          icon: _controller.isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.outbox_rounded),
          label: Text(_controller.isSubmitting ? 'Sending' : 'Submit report'),
        ),
        if (message != null && message.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: message.toLowerCase().contains('sent')
                  ? AppColors.primary800
                  : AppColors.hexFFE53935,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _submitReport() async {
    final bool sent = await _controller.submit();
    if (!sent || !mounted) {
      return;
    }
    _detailsController.clear();
    AppGet.snackbar('Report', 'Report submitted for review.');
  }

  IconData _targetIcon(String key) {
    switch (normalizeReportKey(key)) {
      case 'user':
        return Icons.person_outline_rounded;
      case 'post':
        return Icons.article_outlined;
      case 'reel':
        return Icons.smart_display_outlined;
      case 'story':
        return Icons.auto_stories_outlined;
      case 'comment':
        return Icons.mode_comment_outlined;
      case 'marketplace':
        return Icons.storefront_outlined;
      case 'job':
        return Icons.work_outline_rounded;
      case 'event':
        return Icons.event_outlined;
      case 'community':
        return Icons.groups_2_outlined;
      case 'page':
        return Icons.flag_circle_outlined;
      case 'chat':
        return Icons.forum_outlined;
      case 'live':
        return Icons.sensors_outlined;
      default:
        return Icons.report_gmailerrorred_outlined;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.primary800),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _TargetChoiceTile extends StatelessWidget {
  const _TargetChoiceTile({
    required this.option,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final ReportTargetOptionModel option;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 82,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary50 : AppColors.grey50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary500 : AppColors.grey200,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: selected ? AppColors.primary800 : AppColors.grey700,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.grey600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary800,
              ),
          ],
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

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
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
        color: AppColors.grey50,
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
