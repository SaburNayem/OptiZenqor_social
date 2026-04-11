import 'package:flutter/material.dart';

import '../model/job_model.dart';

class JobProfileScreen extends StatelessWidget {
  const JobProfileScreen({
    required this.role,
    this.careerProfile,
    this.employerProfile,
    this.employerStats,
    this.applicationCount = 0,
    this.savedCount = 0,
    super.key,
  });

  final JobsUserRole role;
  final CareerProfileModel? careerProfile;
  final EmployerProfileModel? employerProfile;
  final EmployerStatsModel? employerStats;
  final int applicationCount;
  final int savedCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          role == JobsUserRole.provider
              ? 'Provider Job Profile'
              : 'Seeker Job Profile',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (role == JobsUserRole.provider && employerProfile != null)
            _providerProfile(context)
          else if (careerProfile != null)
            _seekerProfile(context),
        ],
      ),
    );
  }

  Widget _seekerProfile(BuildContext context) {
    final profile = careerProfile!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerCard(
          context,
          name: profile.name,
          title: profile.title,
          subtitle: profile.availability,
          icon: Icons.person_search_rounded,
        ),
        const SizedBox(height: 16),
        _statsRow(context, [
          _statCard(context, 'Applications', '$applicationCount'),
          _statCard(context, 'Saved jobs', '$savedCount'),
        ]),
        const SizedBox(height: 18),
        _section(context, 'Skills', profile.skills),
        _section(context, 'Experience', profile.experience),
        _section(context, 'Education', profile.education),
        _section(context, 'Portfolio links', profile.portfolioLinks),
        _singleSection(context, 'Resume', profile.resumeLabel),
      ],
    );
  }

  Widget _providerProfile(BuildContext context) {
    final profile = employerProfile!;
    final stats = employerStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerCard(
          context,
          name: profile.companyName,
          title: profile.hiringTitle,
          subtitle: profile.location,
          icon: Icons.business_center_rounded,
        ),
        const SizedBox(height: 16),
        if (stats != null)
          _statsRow(context, [
            _statCard(context, 'Open jobs', '${stats.totalJobs}'),
            _statCard(context, 'Applicants', '${stats.totalApplicants}'),
            _statCard(context, 'Messages', '${stats.messages}'),
          ]),
        const SizedBox(height: 18),
        _singleSection(context, 'About hiring team', profile.about),
        _section(context, 'Hiring focus', profile.hiringFocus),
        _section(context, 'Open roles', profile.openRoles),
        _section(context, 'Team highlights', profile.teamHighlights),
      ],
    );
  }

  Widget _headerCard(
    BuildContext context, {
    required String name,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 28, child: Icon(icon)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(title),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(BuildContext context, List<Widget> children) {
    return Wrap(spacing: 12, runSpacing: 12, children: children);
  }

  Widget _statCard(BuildContext context, String label, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _singleSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(content),
        ],
      ),
    );
  }
}
