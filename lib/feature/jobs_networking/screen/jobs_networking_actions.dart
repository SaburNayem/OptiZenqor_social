part of 'jobs_networking_screen.dart';

extension _JobsNetworkingActions on _JobsNetworkingScreenState {
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _statusState({
    required IconData icon,
    required String title,
    required String description,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(description, textAlign: TextAlign.center),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: onAction, child: Text(actionLabel)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openJobDetails(JobModel job) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JobDetailsScreen(
          job: job,
          onSave: () => _controller.toggleSave(job.id),
          onApply: () => _applyToJob(job),
        ),
      ),
    );
  }

  Future<void> _applyToJob(JobModel job) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JobApplicationFlowScreen(
          job: job,
          onSubmit: (coverLetter, portfolioLink) {
            _controller.applyToJob(
              job.id,
              coverLetter: coverLetter,
              portfolioLink: portfolioLink,
            );
          },
        ),
      ),
    );
  }

  Future<void> _openCreateJob() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateJobScreen(onCreate: _controller.addPostedJob),
      ),
    );
  }

  void _openSavedJobs() {
    _tabController.animateTo(3);
  }

  Future<void> _openMyJobProfile() async {
    final role = _controller.selectedRole;
    if (role == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JobProfileScreen(
          role: role,
          careerProfile: _controller.careerProfile,
          employerProfile: _controller.employerProfile,
          employerStats: _controller.employerStats,
          applicationCount: _controller.applications.length,
          savedCount: _controller.savedJobs.length,
        ),
      ),
    );
  }

  Future<void> _showFilterSheet() async {
    JobFilterModel draft = _controller.filter;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Job filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Location'),
                      controller: TextEditingController(text: draft.location),
                      onChanged: (value) =>
                          draft = draft.copyWith(location: value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<JobType?>(
                      initialValue: draft.jobType,
                      decoration: const InputDecoration(labelText: 'Job type'),
                      items: [
                        const DropdownMenuItem<JobType?>(
                          value: null,
                          child: Text('Any'),
                        ),
                        ...JobType.values.map(
                          (item) => DropdownMenuItem<JobType?>(
                            value: item,
                            child: Text(_jobTypeLabel(item)),
                          ),
                        ),
                      ],
                      onChanged: (value) => setModalState(
                        () => draft = draft.copyWith(
                          jobType: value,
                          clearJobType: value == null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ExperienceLevel?>(
                      initialValue: draft.experienceLevel,
                      decoration: const InputDecoration(
                        labelText: 'Experience level',
                      ),
                      items: [
                        const DropdownMenuItem<ExperienceLevel?>(
                          value: null,
                          child: Text('Any'),
                        ),
                        ...ExperienceLevel.values.map(
                          (item) => DropdownMenuItem<ExperienceLevel?>(
                            value: item,
                            child: Text(_experienceLabel(item)),
                          ),
                        ),
                      ],
                      onChanged: (value) => setModalState(
                        () => draft = draft.copyWith(
                          experienceLevel: value,
                          clearExperience: value == null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: draft.workMode,
                      decoration: const InputDecoration(
                        labelText: 'Remote / Onsite',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Any', child: Text('Any')),
                        DropdownMenuItem(
                          value: 'Remote',
                          child: Text('Remote'),
                        ),
                        DropdownMenuItem(
                          value: 'Hybrid',
                          child: Text('Hybrid'),
                        ),
                        DropdownMenuItem(
                          value: 'Onsite',
                          child: Text('Onsite'),
                        ),
                      ],
                      onChanged: (value) => setModalState(
                        () => draft = draft.copyWith(workMode: value),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: draft.companySize,
                      decoration: const InputDecoration(
                        labelText: 'Company size',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Any', child: Text('Any')),
                        DropdownMenuItem(value: '1-50', child: Text('1-50')),
                        DropdownMenuItem(
                          value: '51-200',
                          child: Text('51-200'),
                        ),
                        DropdownMenuItem(value: '200+', child: Text('200+')),
                      ],
                      onChanged: (value) => setModalState(
                        () => draft = draft.copyWith(companySize: value),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          _controller.updateFilter(draft);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Apply filters'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _createAlert() async {
    final keyword = TextEditingController();
    final location = TextEditingController(text: 'Remote');
    AlertFrequency frequency = AlertFrequency.daily;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create alert',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: keyword,
                    decoration: const InputDecoration(labelText: 'Keyword'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: location,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AlertFrequency>(
                    initialValue: frequency,
                    decoration: const InputDecoration(
                      labelText: 'Notification frequency',
                    ),
                    items: AlertFrequency.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(_alertFrequency(item)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) =>
                        setModalState(() => frequency = value ?? frequency),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        _controller.createAlert(
                          keyword: keyword.text.trim().isEmpty
                              ? 'New jobs'
                              : keyword.text.trim(),
                          location: location.text.trim().isEmpty
                              ? 'Remote'
                              : location.text.trim(),
                          frequency: frequency,
                        );
                        Navigator.of(context).pop();
                      },
                      child: const Text('Create alert'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _applicationStatus(ApplicationStatus status) {
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

  String _alertFrequency(AlertFrequency frequency) {
    switch (frequency) {
      case AlertFrequency.instant:
        return 'Instant';
      case AlertFrequency.daily:
        return 'Daily';
      case AlertFrequency.weekly:
        return 'Weekly';
    }
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

  String _experienceLabel(ExperienceLevel level) {
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

  void _showSnack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}
