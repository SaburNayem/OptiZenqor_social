import 'package:flutter/material.dart';

import '../../../core/common_widget/error_state_view.dart';
import '../controller/polls_surveys_controller.dart';
import '../model/poll_model.dart';
import '../../../core/constants/app_colors.dart';

class PollsSurveysScreen extends StatelessWidget {
  PollsSurveysScreen({super.key}) {
    _controller.load();
  }

  final PollsSurveysController _controller = PollsSurveysController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hexFFF7FAFC,
      appBar: AppBar(title: const Text('Polls & Surveys')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.errorMessage != null) {
            return ErrorStateView(
              message: _controller.errorMessage!,
              onRetry: _controller.load,
            );
          }

          if (_controller.activeEntries.isEmpty &&
              _controller.draftEntries.isEmpty) {
            return RefreshIndicator(
              onRefresh: _controller.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [SizedBox(height: 120), _EmptyPollState()],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _controller.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeroCard(),
                const SizedBox(height: 24),
                if (_controller.activeEntries.isNotEmpty) ...[
                  _buildSectionHeader(title: 'Active'),
                  const SizedBox(height: 12),
                  ..._controller.activeEntries.map(_buildActiveCard),
                  const SizedBox(height: 24),
                ],
                if (_controller.draftEntries.isNotEmpty) ...[
                  _buildSectionHeader(title: 'Drafts'),
                  const SizedBox(height: 12),
                  ..._controller.draftEntries.map(_buildDraftCard),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard() {
    final int liveCount = _controller.activeEntries.length;
    final int draftCount = _controller.draftEntries.length;
    final int responseCount = _controller.activeEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.responseCount,
    );

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
            'This screen reflects only backend-synced polls and surveys. Pull to refresh if the latest entries are missing.',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.78),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricBadge(label: '$liveCount live'),
              _MetricBadge(label: '$draftCount drafts'),
              _MetricBadge(label: '$responseCount responses'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
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
                    child: FilledButton.tonal(
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
          OutlinedButton(onPressed: null, child: const Text('Backend draft')),
        ],
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

class _EmptyPollState extends StatelessWidget {
  const _EmptyPollState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.hexFFE2E8F0),
      ),
      child: const Column(
        children: [
          Icon(Icons.poll_outlined, size: 48, color: AppColors.hexFF64748B),
          SizedBox(height: 12),
          Text(
            'No polls or surveys yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'The backend returned no active or draft entries for this account.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.hexFF64748B, height: 1.5),
          ),
        ],
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
