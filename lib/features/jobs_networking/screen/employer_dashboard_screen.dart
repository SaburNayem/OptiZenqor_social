import 'package:flutter/material.dart';

import '../model/job_model.dart';

class EmployerDashboardScreen extends StatelessWidget {
  const EmployerDashboardScreen({
    required this.stats,
    super.key,
  });

  final EmployerStatsModel stats;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employer dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _statCard('Total jobs', '${stats.totalJobs}'),
              _statCard('Applicants', '${stats.totalApplicants}'),
              _statCard('Shortlisted', '${stats.shortlistedCandidates}'),
              _statCard('Messages', '${stats.messages}'),
            ],
          ),
          const SizedBox(height: 20),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.auto_awesome_rounded),
            title: Text('AI job recommendations'),
            subtitle: Text('Suggested roles based on applicant interest and trend signals'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.trending_up_rounded),
            title: Text('Trending jobs'),
            subtitle: Text('Top performing roles this week'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.security_rounded),
            title: Text('Scam detection'),
            subtitle: Text('No suspicious activity detected'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
