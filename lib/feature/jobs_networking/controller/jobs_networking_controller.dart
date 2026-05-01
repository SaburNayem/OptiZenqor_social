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
  EmployerProfileModel? employerProfile;
  JobFilterModel filter = const JobFilterModel();
  String category = 'Remote';
  String searchQuery = '';
  JobsUserRole? selectedRole;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      jobs = await _repository.listJobs();
      myPostedJobs = await _repository.myJobs();
      applications = await _repository.myApplications();
      alerts = await _repository.alerts();
      companies = await _repository.companies();
      applicants = await _repository.applicants();
      careerProfile = await _repository.profile();
      employerStats = await _repository.employerStats();
      employerProfile = await _repository.employerProfile();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<JobModel> get filteredJobs {
    return jobs
        .where((job) {
          final query = searchQuery.trim().toLowerCase();
          final matchesQuery =
              query.isEmpty ||
              job.title.toLowerCase().contains(query) ||
              job.company.toLowerCase().contains(query) ||
              job.skills.any((skill) => skill.toLowerCase().contains(query));
          final matchesCategory = switch (category) {
            'Remote' => job.remoteFriendly || job.type == JobType.remote,
            'Full-time' => job.type == JobType.fullTime,
            'Part-time' => job.type == JobType.partTime,
            'Freelance' =>
              job.type == JobType.freelance || job.type == JobType.contract,
            'Internship' => job.type == JobType.internship,
            _ => true,
          };
          final matchesLocation =
              filter.location == 'Any' ||
              job.location.toLowerCase().contains(
                filter.location.toLowerCase(),
              );
          final matchesJobType =
              filter.jobType == null || job.type == filter.jobType;
          final matchesExperience =
              filter.experienceLevel == null ||
              job.experienceLevel == filter.experienceLevel;
          final matchesWorkMode =
              filter.workMode == 'Any' ||
              (filter.workMode == 'Remote' && job.remoteFriendly) ||
              job.location.toLowerCase().contains(
                filter.workMode.toLowerCase(),
              );
          return matchesQuery &&
              matchesCategory &&
              matchesLocation &&
              matchesJobType &&
              matchesExperience &&
              matchesWorkMode;
        })
        .toList(growable: false);
  }

  List<JobModel> get recommendedJobs =>
      filteredJobs.where((job) => job.featured).toList(growable: false);
  List<JobModel> get savedJobs =>
      jobs.where((job) => job.saved).toList(growable: false);
  List<JobModel> get activeJobs => myPostedJobs
      .where((job) => !job.closed && !job.draft)
      .toList(growable: false);
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

  Future<void> toggleSave(String id) async {
    try {
      final bool saved = await _repository.toggleSavedJob(id);
      jobs = jobs
          .map((job) => job.id == id ? job.copyWith(saved: saved) : job)
          .toList(growable: false);
      myPostedJobs = myPostedJobs
          .map((job) => job.id == id ? job.copyWith(saved: saved) : job)
          .toList(growable: false);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<void> applyToJob(
    String jobId, {
    String coverLetter = '',
    String portfolioLink = '',
  }) async {
    try {
      await _repository.applyToJob(
        jobId,
        coverLetter: coverLetter,
        portfolioLink: portfolioLink,
      );
      await load();
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> withdrawApplication(String id) async {
    try {
      final JobApplicationModel updated = await _repository.withdrawApplication(
        id,
      );
      applications = applications
          .map((item) => item.id == id ? updated : item)
          .toList(growable: false);
      jobs = jobs
          .map(
            (job) => job.id == updated.jobId
                ? job.copyWith(
                    applied: updated.status != ApplicationStatus.rejected,
                  )
                : job,
          )
          .toList(growable: false);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<void> toggleCompanyFollow(String id) async {
    final CompanyModel? current = companies.cast<CompanyModel?>().firstWhere(
      (company) => company?.id == id,
      orElse: () => null,
    );
    if (current == null) {
      return;
    }
    try {
      final bool followed = await _repository.toggleCompanyFollow(
        id,
        !current.followed,
      );
      companies = companies
          .map(
            (company) => company.id == id
                ? company.copyWith(followed: followed)
                : company,
          )
          .toList(growable: false);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<void> createAlert({
    required String keyword,
    required String location,
    required AlertFrequency frequency,
  }) async {
    try {
      final JobAlertModel alert = await _repository.createAlert(
        keyword: keyword,
        location: location,
        frequency: frequency,
      );
      alerts = <JobAlertModel>[alert, ...alerts];
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<void> toggleAlert(String id) async {
    final JobAlertModel? current = alerts.cast<JobAlertModel?>().firstWhere(
      (alert) => alert?.id == id,
      orElse: () => null,
    );
    if (current == null) {
      return;
    }
    try {
      final JobAlertModel updated = await _repository.toggleAlert(
        id,
        !current.enabled,
      );
      alerts = alerts
          .map((alert) => alert.id == id ? updated : alert)
          .toList(growable: false);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<void> deleteMyJob(String id) async {
    try {
      await _repository.deleteMyJob(id);
      myPostedJobs = myPostedJobs
          .where((job) => job.id != id)
          .toList(growable: false);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    }
    notifyListeners();
  }

  void addPostedJob(JobModel job) {
    myPostedJobs = <JobModel>[job, ...myPostedJobs];
    notifyListeners();
  }

  Future<void> updateApplicantStatus(
    String applicationId,
    ApplicationStatus status,
  ) async {
    try {
      final ApplicantModel updated = await _repository.updateApplicantStatus(
        applicationId,
        status,
      );
      applicants = applicants
          .map((applicant) => applicant.id == updated.id ? updated : applicant)
          .toList(growable: false);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    }
    notifyListeners();
  }

  void selectRole(JobsUserRole role) {
    selectedRole = role;
    notifyListeners();
  }
}
