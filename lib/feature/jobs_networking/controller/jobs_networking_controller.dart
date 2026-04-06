import 'package:flutter/foundation.dart';

import '../model/job_application_model.dart';
import '../model/job_filter_model.dart';
import '../model/job_model.dart';
import '../repository/jobs_networking_repository.dart';

class JobsNetworkingController extends ChangeNotifier {
  JobsNetworkingController({JobsNetworkingRepository? repository})
      : _repository = repository ?? JobsNetworkingRepository();

  final JobsNetworkingRepository _repository;

  List<JobModel> jobs = <JobModel>[];
  List<JobModel> myPostedJobs = <JobModel>[];
  List<JobApplicationModel> applications = <JobApplicationModel>[];
  List<JobAlertModel> alerts = <JobAlertModel>[];
  List<CompanyModel> companies = <CompanyModel>[];
  List<ApplicantModel> applicants = <ApplicantModel>[];
  CareerProfileModel? careerProfile;
  EmployerStatsModel? employerStats;
  JobFilterModel filter = const JobFilterModel();
  String category = 'Remote';
  String searchQuery = '';

  void load() {
    jobs = _repository.listJobs();
    myPostedJobs = _repository.myJobs();
    applications = _repository.myApplications();
    alerts = _repository.alerts();
    companies = _repository.companies();
    applicants = _repository.applicants();
    careerProfile = _repository.profile();
    employerStats = _repository.employerStats();
    notifyListeners();
  }

  List<JobModel> get filteredJobs {
    return jobs.where((job) {
      final query = searchQuery.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          job.title.toLowerCase().contains(query) ||
          job.company.toLowerCase().contains(query) ||
          job.skills.any((skill) => skill.toLowerCase().contains(query));
      final matchesCategory = switch (category) {
        'Remote' => job.remoteFriendly || job.type == JobType.remote,
        'Full-time' => job.type == JobType.fullTime,
        'Part-time' => job.type == JobType.partTime,
        'Freelance' => job.type == JobType.freelance || job.type == JobType.contract,
        'Internship' => job.type == JobType.internship,
        _ => true,
      };
      final matchesLocation = filter.location == 'Any' ||
          job.location.toLowerCase().contains(filter.location.toLowerCase());
      final matchesJobType = filter.jobType == null || job.type == filter.jobType;
      final matchesExperience =
          filter.experienceLevel == null || job.experienceLevel == filter.experienceLevel;
      final matchesWorkMode = filter.workMode == 'Any' ||
          (filter.workMode == 'Remote' && job.remoteFriendly) ||
          job.location.toLowerCase().contains(filter.workMode.toLowerCase());
      return matchesQuery &&
          matchesCategory &&
          matchesLocation &&
          matchesJobType &&
          matchesExperience &&
          matchesWorkMode;
    }).toList(growable: false);
  }

  List<JobModel> get recommendedJobs =>
      filteredJobs.where((job) => job.featured).toList(growable: false);
  List<JobModel> get savedJobs =>
      jobs.where((job) => job.saved).toList(growable: false);
  List<JobModel> get activeJobs =>
      myPostedJobs.where((job) => !job.closed && !job.draft).toList(growable: false);
  List<JobModel> get closedJobs =>
      myPostedJobs.where((job) => job.closed).toList(growable: false);
  List<JobModel> get draftJobs =>
      myPostedJobs.where((job) => job.draft).toList(growable: false);

  void setCategory(String value) {
    category = value;
    notifyListeners();
  }

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void updateFilter(JobFilterModel value) {
    filter = value;
    notifyListeners();
  }

  void toggleSave(String id) {
    jobs = jobs
        .map((job) => job.id == id ? job.copyWith(saved: !job.saved) : job)
        .toList(growable: false);
    myPostedJobs = myPostedJobs
        .map((job) => job.id == id ? job.copyWith(saved: !job.saved) : job)
        .toList(growable: false);
    notifyListeners();
  }

  void applyToJob(String jobId, {String coverLetter = '', String portfolioLink = ''}) {
    jobs = jobs
        .map((job) => job.id == jobId ? job.copyWith(applied: true) : job)
        .toList(growable: false);
    final exists = applications.any((application) => application.jobId == jobId);
    if (!exists) {
      applications = <JobApplicationModel>[
        JobApplicationModel(
          id: 'app_${DateTime.now().millisecondsSinceEpoch}',
          jobId: jobId,
          applicantName: careerProfile?.name ?? 'You',
          status: ApplicationStatus.pending,
          appliedDate: 'Today',
          timeline: const <String>[
            'Application submitted',
            'Recruiter review pending',
          ],
          coverLetter: coverLetter,
          portfolioLink: portfolioLink,
          resumeLabel: careerProfile?.resumeLabel ?? 'Primary resume',
        ),
        ...applications,
      ];
    }
    notifyListeners();
  }

  void withdrawApplication(String id) {
    applications = applications.where((item) => item.id != id).toList(growable: false);
    notifyListeners();
  }

  void toggleCompanyFollow(String id) {
    companies = companies
        .map((company) => company.id == id ? company.copyWith(followed: !company.followed) : company)
        .toList(growable: false);
    notifyListeners();
  }

  void createAlert({
    required String keyword,
    required String location,
    required AlertFrequency frequency,
  }) {
    alerts = <JobAlertModel>[
      JobAlertModel(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        keyword: keyword,
        location: location,
        frequency: frequency,
      ),
      ...alerts,
    ];
    notifyListeners();
  }

  void toggleAlert(String id) {
    alerts = alerts
        .map((alert) => alert.id == id ? alert.copyWith(enabled: !alert.enabled) : alert)
        .toList(growable: false);
    notifyListeners();
  }

  void deleteMyJob(String id) {
    myPostedJobs = myPostedJobs.where((job) => job.id != id).toList(growable: false);
    notifyListeners();
  }

  void addPostedJob(JobModel job) {
    myPostedJobs = <JobModel>[job, ...myPostedJobs];
    notifyListeners();
  }

  void updateApplicantStatus(String id, ApplicationStatus status) {
    applicants = applicants
        .map((applicant) => applicant.id == id ? applicant.copyWith(status: status) : applicant)
        .toList(growable: false);
    notifyListeners();
  }
}
