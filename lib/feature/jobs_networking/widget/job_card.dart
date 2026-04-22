import 'package:flutter/material.dart';

import '../model/job_model.dart';
import '../../../core/constants/app_colors.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    required this.job,
    required this.onTap,
    required this.onSave,
    required this.onApply,
    this.compact = false,
    super.key,
  });

  final JobModel job;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onApply;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.all(compact ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 44 : 50,
                    height: compact ? 44 : 50,
                    decoration: BoxDecoration(
                      color: Color(job.logoColorValue),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        job.logoInitial,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.title,
                                style: TextStyle(
                                  fontSize: compact ? 15 : 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (job.verifiedEmployer)
                              const Icon(
                                Icons.verified_rounded,
                                size: 18,
                                color: AppColors.hexFF2563EB,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.company,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onSave,
                    icon: Icon(
                      job.saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _pill(context, Icons.location_on_outlined, job.location),
                  _pill(
                    context,
                    Icons.work_outline_rounded,
                    _jobTypeLabel(job.type),
                  ),
                  if (job.salary.isNotEmpty)
                    _pill(context, Icons.attach_money_rounded, job.salary),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job.description,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      job.postedTime,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (job.quickApplyEnabled)
                        TextButton(
                          onPressed: onApply,
                          child: const Text('Quick apply'),
                        ),
                      SizedBox(
                        width: compact ? 84 : 96,
                        child: FilledButton(
                          onPressed: onApply,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            job.applied ? 'Applied' : 'Apply',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _jobTypeLabel(JobType type) {
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
}

