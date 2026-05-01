import 'package:flutter/material.dart';

import '../model/job_application_model.dart';
import '../model/job_model.dart';

class ApplicantManagementScreen extends StatefulWidget {
  const ApplicantManagementScreen({
    required this.applicants,
    required this.onStatusChanged,
    super.key,
  });

  final List<ApplicantModel> applicants;
  final void Function(String id, ApplicationStatus status) onStatusChanged;

  @override
  State<ApplicantManagementScreen> createState() =>
      _ApplicantManagementScreenState();
}

class _ApplicantManagementScreenState extends State<ApplicantManagementScreen> {
  String _filter = 'All';
  late List<ApplicantModel> _applicants;

  @override
  void initState() {
    super.initState();
    _applicants = widget.applicants;
  }

  @override
  Widget build(BuildContext context) {
    final applicants = _applicants
        .where((applicant) {
          if (_filter == 'All') {
            return true;
          }
          return _statusLabel(applicant.status) == _filter;
        })
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: ['All', 'Pending', 'Viewed', 'Shortlisted', 'Rejected']
                .map(
                  (item) => ChoiceChip(
                    label: Text(item),
                    selected: _filter == item,
                    onSelected: (_) => setState(() => _filter = item),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 18),
          ...applicants.map((applicant) => _tile(context, applicant)),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, ApplicantModel applicant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person_outline_rounded)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(applicant.title),
                    ],
                  ),
                ),
                Chip(label: Text(_statusLabel(applicant.status))),
              ],
            ),
            const SizedBox(height: 10),
            Text('Skills: ${applicant.skills.join(', ')}'),
            const SizedBox(height: 6),
            Text('Resume: ${applicant.resumeLabel}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => _snack(context, 'View ${applicant.name}'),
                  child: const Text('View profile'),
                ),
                OutlinedButton(
                  onPressed: () => _snack(context, 'Message ${applicant.name}'),
                  child: const Text('Message'),
                ),
                FilledButton(
                  onPressed: () =>
                      _setStatus(applicant.id, ApplicationStatus.shortlisted),
                  child: const Text('Shortlist'),
                ),
                FilledButton.tonal(
                  onPressed: () =>
                      _setStatus(applicant.id, ApplicationStatus.rejected),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.viewed:
        return 'Viewed';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _setStatus(String id, ApplicationStatus status) {
    setState(() {
      _applicants = _applicants
          .map(
            (applicant) => applicant.id == id
                ? applicant.copyWith(status: status)
                : applicant,
          )
          .toList(growable: false);
    });
    widget.onStatusChanged(id, status);
  }
}
