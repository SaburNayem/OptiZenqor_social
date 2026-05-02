import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../controller/polls_surveys_controller.dart';
import '../model/poll_model.dart';
import '../../../core/constants/app_colors.dart';

class PollsSurveysScreen extends StatelessWidget {
  PollsSurveysScreen({super.key}) {
    _controller.load();
  }

  final PollsSurveysController _controller = PollsSurveysController();

  void _showUnavailableMessage(String label) {
    AppGet.snackbar(
      label,
      'This action is not available until the backend composer flow is implemented.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hexFFF7FAFC,
      appBar: AppBar(
        title: const Text('Polls & Surveys'),
        actions: [
          TextButton.icon(
            onPressed: () => _showUnavailableMessage('Create'),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Create'),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeroCard(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildSectionHeader(
                title: 'Quick templates',
                actionLabel: 'See all',
                onTap: () => _showUnavailableMessage('Templates'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _controller.quickTemplates.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final template = _controller.quickTemplates[index];
                    return ActionChip(
                      label: Text(template),
                      onPressed: () =>
                          _showUnavailableMessage('Template selected'),
                      backgroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.hexFFE2E8F0),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(
                title: 'Active section',
                actionLabel: 'Analytics',
                onTap: () => _showUnavailableMessage('Analytics'),
              ),
              const SizedBox(height: 12),
              ..._controller.activeEntries.map(_buildActiveCard),
              const SizedBox(height: 24),
              _buildSectionHeader(
                title: 'Drafts',
                actionLabel: 'Manage',
                onTap: () => _showUnavailableMessage('Drafts'),
              ),
              const SizedBox(height: 12),
              ..._controller.draftEntries.map(_buildDraftCard),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: <Color>[AppColors.hexFF0F172A, AppColors.hexFF1D4ED8],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Profile engagement tools',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Create polls and surveys your audience can answer directly from your profile.',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 22,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ask quick opinion questions, collect structured feedback, and keep drafts ready for the next campaign.',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.78),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _MetricBadge(label: '2 live'),
              _MetricBadge(label: '2 drafts'),
              _MetricBadge(label: '172 responses'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.poll_outlined,
            title: 'Create poll',
            subtitle: 'Fast yes/no or multi-choice vote',
            backgroundColor: AppColors.hexFFE0F2FE,
            iconColor: AppColors.hexFF0284C7,
            onTap: () => _showUnavailableMessage('Create Poll'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.assignment_outlined,
            title: 'Create survey',
            subtitle: 'Gather deeper profile feedback',
            backgroundColor: AppColors.hexFFDCFCE7,
            iconColor: AppColors.hexFF16A34A,
            onTap: () => _showUnavailableMessage('Create Survey'),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        TextButton(onPressed: onTap, child: Text(actionLabel)),
      ],
    );
  }

  Widget _buildActiveCard(PollModel entry) {
    final totalVotes = entry.votes.fold<int>(0, (sum, vote) => sum + vote);
    final safeTotalVotes = totalVotes == 0 ? 1 : totalVotes;
    final accentColor = Color(entry.accentHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.hexFFE2E8F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  entry.type == PollEntryType.poll ? 'Poll' : 'Survey',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.statusLabel,
                style: const TextStyle(
                  color: AppColors.hexFF64748B,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showUnavailableMessage('More'),
                icon: const Icon(Icons.more_horiz),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            entry.question,
            style: const TextStyle(color: AppColors.hexFF475569, height: 1.45),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(label: entry.audienceLabel),
              _InfoPill(label: entry.endsInLabel),
              _InfoPill(label: '${entry.responseCount} responses'),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(entry.options.length, (index) {
            final voteCount = entry.votes[index];
            final percent = (voteCount / safeTotalVotes) * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.options[index],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${percent.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: AppColors.hexFF64748B,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: voteCount / safeTotalVotes,
                      minHeight: 10,
                      backgroundColor: AppColors.hexFFE2E8F0,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _controller.vote(entry.id, index),
                      child: const Text('Vote'),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDraftCard(PollModel entry) {
    final accentColor = Color(entry.accentHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.hexFFE2E8F0),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              entry.type == PollEntryType.poll
                  ? Icons.poll_outlined
                  : Icons.assignment_outlined,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.hexFF64748B,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${entry.statusLabel} | ${entry.audienceLabel}',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => _showUnavailableMessage('Edit draft'),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.hexFFE2E8F0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.hexFF64748B, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.hexFFF8FAFC,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.hexFFE2E8F0),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.hexFF475569,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
