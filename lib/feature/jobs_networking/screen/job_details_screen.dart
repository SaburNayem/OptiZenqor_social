import 'package:flutter/material.dart';

import '../model/job_model.dart';
import '../../../core/constants/app_colors.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({
    required this.job,
    required this.onSave,
    required this.onApply,
    super.key,
  });

  final JobModel job;
  final VoidCallback onSave;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job details'),
        actions: [
          IconButton(onPressed: onSave, icon: Icon(job.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded)),
          IconButton(onPressed: () => _showSnack(context, 'Share job'), icon: const Icon(Icons.share_outlined)),
          IconButton(onPressed: () => _showSnack(context, 'Report job'), icon: const Icon(Icons.flag_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(job.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(job.logoColorValue),
                child: Text(job.logoInitial, style: const TextStyle(color: AppColors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(job.company, style: const TextStyle(fontWeight: FontWeight.w700))),
                        if (job.verifiedEmployer) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, size: 18, color: AppColors.hexFF2563EB),
                        ],
                      ],
                    ),
                    Text(job.location),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(context, job.salary),
              _pill(context, _type(job.type)),
              _pill(context, _level(job.experienceLevel)),
              if (job.deadlineLabel != null) _pill(context, 'Deadline: ${job.deadlineLabel}'),
            ],
          ),
          const SizedBox(height: 20),
          _section('Description', job.description),
          _sectionList('Responsibilities', job.responsibilities),
          _sectionList('Requirements', job.requirements),
          _sectionList('Skills required', job.skills),
          _sectionList('Benefits', job.benefits),
          _section('About company', job.aboutCompany),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: onApply,
                child: Text(job.applied ? 'Applied' : 'Apply now'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: onSave,
                child: Text(job.saved ? 'Saved' : 'Save job'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }

  Widget _sectionList(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(item)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }

  String _type(JobType type) {
    switch (type) {
      case JobType.remote:
        return 'Remote';
      case JobType.fullTime:
        return 'Full-time';
      case JobType.partTime:
        return 'Part-time';
      case JobType.freelance:
        return 'Freelance';
      case JobType.internship:
        return 'Internship';
      case JobType.contract:
        return 'Contract';
      case JobType.hybrid:
        return 'Hybrid';
      case JobType.onsite:
        return 'On-site';
    }
  }

  String _level(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.entry:
        return 'Entry';
      case ExperienceLevel.mid:
        return 'Mid';
      case ExperienceLevel.senior:
        return 'Senior';
      case ExperienceLevel.lead:
        return 'Lead';
    }
  }

  void _showSnack(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

