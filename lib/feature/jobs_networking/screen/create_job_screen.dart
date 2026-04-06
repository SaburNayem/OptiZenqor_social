import 'package:flutter/material.dart';

import '../model/job_model.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({
    required this.onCreate,
    super.key,
  });

  final ValueChanged<JobModel> onCreate;

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _title = TextEditingController();
  final _company = TextEditingController();
  final _location = TextEditingController(text: 'Remote');
  final _salary = TextEditingController();
  final _description = TextEditingController();
  final _requirements = TextEditingController();
  final _skills = TextEditingController();
  final _benefits = TextEditingController();
  final _deadline = TextEditingController(text: 'May 1');
  final _contact = TextEditingController();
  JobType _type = JobType.fullTime;
  ExperienceLevel _level = ExperienceLevel.mid;
  bool _quickApply = true;
  bool _externalApply = false;

  @override
  void dispose() {
    _title.dispose();
    _company.dispose();
    _location.dispose();
    _salary.dispose();
    _description.dispose();
    _requirements.dispose();
    _skills.dispose();
    _benefits.dispose();
    _deadline.dispose();
    _contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create job')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_title, 'Job title'),
          _field(_company, 'Company name'),
          _field(_location, 'Location / Remote'),
          _field(_salary, 'Salary range'),
          DropdownButtonFormField<JobType>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Job type'),
            items: JobType.values
                .map((item) => DropdownMenuItem(value: item, child: Text(_typeLabel(item))))
                .toList(growable: false),
            onChanged: (value) => setState(() => _type = value ?? _type),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ExperienceLevel>(
            value: _level,
            decoration: const InputDecoration(labelText: 'Experience level'),
            items: ExperienceLevel.values
                .map((item) => DropdownMenuItem(value: item, child: Text(_levelLabel(item))))
                .toList(growable: false),
            onChanged: (value) => setState(() => _level = value ?? _level),
          ),
          const SizedBox(height: 12),
          _field(_description, 'Description', maxLines: 4),
          _field(_requirements, 'Requirements', maxLines: 4),
          _field(_skills, 'Skills', hint: 'Flutter, Dart, APIs'),
          _field(_benefits, 'Benefits', hint: 'Healthcare, Bonus, Remote stipend'),
          _field(_deadline, 'Application deadline'),
          _field(_contact, 'Contact email / link'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable quick apply'),
            value: _quickApply,
            onChanged: (value) => setState(() => _quickApply = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Allow external apply link'),
            value: _externalApply,
            onChanged: (value) => setState(() => _externalApply = value),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            child: const Text('Publish job'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }

  void _submit() {
    final title = _title.text.trim();
    final company = _company.text.trim();
    if (title.isEmpty || company.isEmpty) {
      return;
    }
    widget.onCreate(
      JobModel(
        id: 'created_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        company: company,
        location: _location.text.trim().isEmpty ? 'Remote' : _location.text.trim(),
        salary: _salary.text.trim(),
        type: _type,
        experienceLevel: _level,
        postedTime: 'Just now',
        logoInitial: company.characters.first.toUpperCase(),
        logoColorValue: 0xFF2563EB,
        description: _description.text.trim(),
        responsibilities: const ['Review applications', 'Collaborate with team', 'Deliver outcomes'],
        requirements: _split(_requirements.text),
        skills: _split(_skills.text),
        benefits: _split(_benefits.text),
        aboutCompany: '$company is hiring through the local jobs module.',
        quickApplyEnabled: _quickApply,
        verifiedEmployer: true,
        externalApplyEnabled: _externalApply,
        contactLink: _contact.text.trim().isEmpty ? null : _contact.text.trim(),
        deadlineLabel: _deadline.text.trim().isEmpty ? null : _deadline.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  List<String> _split(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String _typeLabel(JobType type) {
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

  String _levelLabel(ExperienceLevel level) {
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
}
