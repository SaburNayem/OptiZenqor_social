import 'package:flutter/material.dart';
import 'package:optizenqor_social/app_route/route_names.dart';

import '../../../core/navigation/app_get.dart';
import '../controller/jobs_networking_controller.dart';
import '../model/job_filter_model.dart';
import '../model/job_model.dart';
import '../widget/job_card.dart';
import 'applicant_management_screen.dart';
import 'career_profile_screen.dart';
import 'create_job_screen.dart';
import 'employer_dashboard_screen.dart';
import 'job_application_flow_screen.dart';
import 'job_details_screen.dart';
import 'job_profile_screen.dart';
import '../../../core/constants/app_colors.dart';

class JobsNetworkingScreen extends StatefulWidget {
  const JobsNetworkingScreen({super.key});

  @override
  State<JobsNetworkingScreen> createState() => _JobsNetworkingScreenState();
}

class _JobsNetworkingScreenState extends State<JobsNetworkingScreen>
    with SingleTickerProviderStateMixin {
  final JobsNetworkingController _controller = JobsNetworkingController();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _controller.load();
    _searchController.addListener(() {
      _controller.updateSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final role = _controller.selectedRole;
        return Scaffold(
          body: role == null ? _roleSelectionView() : _jobsScaffold(role),
          floatingActionButton: role == JobsUserRole.provider
              ? FloatingActionButton.extended(
                  onPressed: _openCreateJob,
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('Post job'),
                )
              : null,
        );
      },
    );
  }

  Widget _roleSelectionView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'How do you want to use jobs?',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              'Choose whether you are exploring opportunities as a job seeker or posting roles as a job provider.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            _roleCard(
              title: 'Job seeker',
              subtitle:
                  'Discover jobs, manage applications, save roles, and keep a job-focused profile.',
              icon: Icons.person_search_rounded,
              onTap: () => _controller.selectRole(JobsUserRole.seeker),
            ),
            const SizedBox(height: 14),
            _roleCard(
              title: 'Job provider',
              subtitle:
                  'Create jobs, manage applicants, track hiring activity, and maintain your hiring profile.',
              icon: Icons.business_center_rounded,
              onTap: () => _controller.selectRole(JobsUserRole.provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 28, child: Icon(icon)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Widget _jobsScaffold(JobsUserRole role) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            pinned: true,
            floating: true,
            title: Text(
              role == JobsUserRole.provider ? 'Jobs Provider' : 'Jobs Seeker',
            ),
            actions: [
              IconButton(
                onPressed: _showFilterSheet,
                icon: const Icon(Icons.tune_rounded),
              ),
              if (role == JobsUserRole.seeker)
                IconButton(
                  onPressed: _openSavedJobs,
                  icon: const Icon(Icons.bookmark_border_rounded),
                ),
              IconButton(
                onPressed: () => AppGet.toNamed(RouteNames.notifications),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: _openMyJobProfile,
                  borderRadius: BorderRadius.circular(999),
                  child: CircleAvatar(
                    radius: 18,
                    child: Text(role == JobsUserRole.provider ? 'P' : 'S'),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(122),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: role == JobsUserRole.provider
                            ? 'Search jobs, applicants, company'
                            : 'Search jobs, company, keyword',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: role == JobsUserRole.provider
                        ? const [
                            Tab(text: 'Discover'),
                            Tab(text: 'Create'),
                            Tab(text: 'My Jobs'),
                            Tab(text: 'Applicants'),
                            Tab(text: 'Alerts'),
                          ]
                        : const [
                            Tab(text: 'Discover'),
                            Tab(text: 'Career'),
                            Tab(text: 'Applications'),
                            Tab(text: 'Saved'),
                            Tab(text: 'Alerts'),
                          ],
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: _jobsBody(role),
    );
  }

  Widget _jobsBody(JobsUserRole role) {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null &&
        _controller.errorMessage!.trim().isNotEmpty) {
      return _statusState(
        icon: Icons.error_outline_rounded,
        title: 'Could not load jobs',
        description: _controller.errorMessage!,
        actionLabel: 'Retry',
        onAction: _controller.load,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: role == JobsUserRole.provider
          ? [
              _discoverTab(),
              _createTab(),
              _myJobsTab(),
              _applicantsTab(),
              _alertsTab(),
            ]
          : [
              _discoverTab(),
              _careerTab(),
              _applicationsTab(),
              _savedTab(),
              _alertsTab(),
            ],
    );
  }

  Widget _discoverTab() {
    final jobs = _controller.filteredJobs;
    if (jobs.isEmpty && _controller.companies.isEmpty) {
      return _statusState(
        icon: Icons.work_outline_rounded,
        title: 'No jobs available yet',
        description:
            'There are no backend jobs or featured companies to show right now.',
        actionLabel: 'Refresh',
        onAction: _controller.load,
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:
                ['Remote', 'Full-time', 'Part-time', 'Freelance', 'Internship']
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(item),
                          selected: _controller.category == item,
                          onSelected: (_) => _controller.setCategory(item),
                        ),
                      ),
                    )
                    .toList(growable: false),
          ),
        ),
        const SizedBox(height: 20),
        _sectionHeader('Recommended jobs'),
        ..._controller.recommendedJobs.map(
          (job) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: JobCard(
              job: job,
              onTap: () => _openJobDetails(job),
              onSave: () => _controller.toggleSave(job.id),
              onApply: () => _applyToJob(job),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _sectionHeader('Featured companies'),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _controller.companies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final company = _controller.companies[index];
              return Container(
                width: 220,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(company.colorValue),
                      child: Text(company.logoInitial),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            company.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (company.verified)
                          const Icon(
                            Icons.verified_rounded,
                            size: 18,
                            color: AppColors.hexFF2563EB,
                          ),
                      ],
                    ),
                    Text(company.tagline),
                    const Spacer(),
                    Row(
                      children: [
                        Text('${company.followers} followers'),
                        const Spacer(),
                        FilledButton.tonal(
                          onPressed: () =>
                              _controller.toggleCompanyFollow(company.id),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            company.followed ? 'Following' : 'Follow',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _sectionHeader('Latest jobs'),
        ...jobs.map(
          (job) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: JobCard(
              job: job,
              onTap: () => _openJobDetails(job),
              onSave: () => _controller.toggleSave(job.id),
              onApply: () => _applyToJob(job),
              compact: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _careerTab() {
    final profile = _controller.careerProfile;
    if (profile == null) {
      return _statusState(
        icon: Icons.person_search_outlined,
        title: 'No career profile yet',
        description:
            'Your backend career profile is empty or has not been created yet.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      child: Icon(Icons.person_search_rounded),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(profile.title),
                          const SizedBox(height: 4),
                          Text(
                            profile.availability,
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
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.skills
                      .map((skill) => Chip(label: Text(skill)))
                      .toList(growable: false),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CareerProfileScreen(profile: profile),
                    ),
                  ),
                  child: const Text('Open full career profile'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        _sectionHeader('Experience'),
        ...profile.experience.map(
          (item) =>
              ListTile(contentPadding: EdgeInsets.zero, title: Text(item)),
        ),
        const SizedBox(height: 18),
        _sectionHeader('Portfolio'),
        ...profile.portfolioLinks.map(
          (item) =>
              ListTile(contentPadding: EdgeInsets.zero, title: Text(item)),
        ),
      ],
    );
  }

  Widget _createTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create and manage jobs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Post new openings, keep drafts organized, and move quickly from role creation to applicant review.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _openCreateJob,
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('Create new job'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    Chip(label: Text('Draft jobs')),
                    Chip(label: Text('Hiring templates')),
                    Chip(label: Text('Application review')),
                    Chip(label: Text('Promoted listings')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (_controller.employerStats != null) _dashboardCard(),
      ],
    );
  }

  Widget _myJobsTab() {
    if (_controller.myPostedJobs.isEmpty) {
      return _statusState(
        icon: Icons.add_business_outlined,
        title: 'No posted jobs yet',
        description: 'You have not created any backend job listings yet.',
        actionLabel: 'Create job',
        onAction: _openCreateJob,
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        if (_controller.employerStats != null) _dashboardCard(),
        const SizedBox(height: 18),
        _sectionHeader('Jobs posted by me'),
        ..._controller.myPostedJobs.map(_employerJobTile),
        const SizedBox(height: 18),
        _sectionHeader('Active jobs'),
        ..._controller.activeJobs.map(_employerJobTile),
        const SizedBox(height: 18),
        _sectionHeader('Closed jobs'),
        ..._controller.closedJobs.map(_employerJobTile),
        const SizedBox(height: 18),
        _sectionHeader('Draft jobs'),
        ..._controller.draftJobs.map(_employerJobTile),
      ],
    );
  }

  Widget _applicationsTab() {
    if (_controller.applications.isEmpty) {
      return _statusState(
        icon: Icons.assignment_outlined,
        title: 'No applications yet',
        description: 'You have not applied to any backend job listings yet.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: _controller.applications
          .map((application) {
            final job = _controller.jobs.firstWhere(
              (item) => item.id == application.jobId,
              orElse: () => _controller.jobs.first,
            );
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text('${job.company} • ${application.appliedDate}'),
                    const SizedBox(height: 10),
                    Chip(label: Text(_applicationStatus(application.status))),
                    const SizedBox(height: 10),
                    ...application.timeline.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(item)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          _controller.withdrawApplication(application.id),
                      child: const Text('Withdraw application'),
                    ),
                  ],
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }

  Widget _applicantsTab() {
    if (_controller.applicants.isEmpty) {
      return _statusState(
        icon: Icons.groups_outlined,
        title: 'No applicants yet',
        description:
            'There are no applicant records from the backend for your jobs yet.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        FilledButton.tonalIcon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ApplicantManagementScreen(
                applicants: _controller.applicants,
                onStatusChanged: _controller.updateApplicantStatus,
              ),
            ),
          ),
          icon: const Icon(Icons.groups_rounded),
          label: const Text('Open applicant management'),
        ),
        const SizedBox(height: 18),
        ..._controller.applicants.map(
          (applicant) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
              title: Text(applicant.name),
              subtitle: Text(
                '${applicant.title} • ${applicant.skills.join(', ')}',
              ),
              trailing: Chip(label: Text(_applicationStatus(applicant.status))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _savedTab() {
    if (_controller.savedJobs.isEmpty) {
      return _statusState(
        icon: Icons.bookmark_border_rounded,
        title: 'No saved jobs yet',
        description: 'Saved backend job listings will appear here.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: _controller.savedJobs
          .map(
            (job) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JobCard(
                job: job,
                onTap: () => _openJobDetails(job),
                onSave: () => _controller.toggleSave(job.id),
                onApply: () => _applyToJob(job),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _alertsTab() {
    if (_controller.alerts.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          FilledButton.tonalIcon(
            onPressed: _createAlert,
            icon: const Icon(Icons.add_alert_rounded),
            label: const Text('Create job alert'),
          ),
          const SizedBox(height: 18),
          _statusState(
            icon: Icons.notifications_active_outlined,
            title: 'No alerts yet',
            description:
                'Create a backend job alert to start tracking openings.',
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        FilledButton.tonalIcon(
          onPressed: _createAlert,
          icon: const Icon(Icons.add_alert_rounded),
          label: const Text('Create job alert'),
        ),
        const SizedBox(height: 18),
        ..._controller.alerts.map(
          (alert) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: alert.enabled,
            onChanged: (_) => _controller.toggleAlert(alert.id),
            title: Text(alert.keyword),
            subtitle: Text(
              '${alert.location} • ${_alertFrequency(alert.frequency)}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _dashboardCard() {
    final stats = _controller.employerStats!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employer dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _metric('Total jobs', '${stats.totalJobs}'),
                _metric('Applicants', '${stats.totalApplicants}'),
                _metric('Shortlisted', '${stats.shortlistedCandidates}'),
                _metric('Messages', '${stats.messages}'),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EmployerDashboardScreen(stats: stats),
                    ),
                  ),
                  child: const Text('Open dashboard'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ApplicantManagementScreen(
                        applicants: _controller.applicants,
                        onStatusChanged: _controller.updateApplicantStatus,
                      ),
                    ),
                  ),
                  child: const Text('View applicants'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _employerJobTile(JobModel job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (job.draft) const Chip(label: Text('Draft')),
                if (job.closed) const Chip(label: Text('Closed')),
              ],
            ),
            const SizedBox(height: 4),
            Text('${job.company} • ${job.location}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => _showSnack('Edit ${job.title}'),
                  child: const Text('Edit'),
                ),
                OutlinedButton(
                  onPressed: () => _controller.deleteMyJob(job.id),
                  child: const Text('Delete'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ApplicantManagementScreen(
                        applicants: _controller.applicants,
                        onStatusChanged: _controller.updateApplicantStatus,
                      ),
                    ),
                  ),
                  child: const Text('View applicants'),
                ),
                OutlinedButton(
                  onPressed: () => _showSnack('Promote ${job.title}'),
                  child: const Text('Promote'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
