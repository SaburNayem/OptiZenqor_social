import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/job_application_model.dart';
import '../model/job_model.dart';
import '../service/jobs_networking_service.dart';

class JobsNetworkingRepository {
  JobsNetworkingRepository({JobsNetworkingService? service})
    : _service = service ?? JobsNetworkingService();

  final JobsNetworkingService _service;

  Map<String, dynamic>? _jobsNetworkingPayload;

  Future<List<JobModel>> listJobs() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('jobs');
    if (response.isSuccess && response.data['success'] != false) {
      final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
        response.data,
        preferredKeys: const <String>['jobs', 'items'],
      );
      if (items.isNotEmpty) {
        return items
            .map(JobModel.fromApiJson)
            .where((JobModel item) => item.id.isNotEmpty)
            .toList(growable: false);
      }
    }
    return const <JobModel>[];
  }

  Future<List<JobModel>> myJobs() async {
    final List<Map<String, dynamic>> items = await _readJobList(
      aggregateKey: 'myJobs',
      endpoint: ApiEndPoints.jobsNetworking,
      preferredKeys: const <String>['myJobs'],
    );
    return items
        .map(JobModel.fromApiJson)
        .where((JobModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<JobApplicationModel>> myApplications() async {
    final List<Map<String, dynamic>> items = await _readJobList(
      aggregateKey: 'applications',
      endpoint: ApiEndPoints.jobsApplications,
      preferredKeys: const <String>['applications'],
    );
    return items
        .map(_applicationFromApiJson)
        .where((JobApplicationModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<JobAlertModel>> alerts() async {
    final List<Map<String, dynamic>> items = await _readJobList(
      aggregateKey: 'alerts',
      endpoint: ApiEndPoints.jobsAlerts,
      preferredKeys: const <String>['alerts'],
    );
    return items
        .map(_alertFromApiJson)
        .where((JobAlertModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<CompanyModel>> companies() async {
    final List<Map<String, dynamic>> items = await _readJobList(
      aggregateKey: 'companies',
      endpoint: ApiEndPoints.jobsCompanies,
      preferredKeys: const <String>['companies'],
    );
    return items
        .map(_companyFromApiJson)
        .where((CompanyModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<CareerProfileModel?> profile() async {
    final Map<String, dynamic>? aggregatePayload =
        await _readAggregatePayload();
    final Map<String, dynamic>? aggregateProfile = ApiPayloadReader.readMap(
      aggregatePayload?['profile'],
    );
    if (aggregateProfile != null && aggregateProfile.isNotEmpty) {
      return CareerProfileModel.fromApiJson(aggregateProfile);
    }

    final ServiceResponseModel<Map<String, dynamic>> rawResponse =
        await _service.apiClient.get(ApiEndPoints.jobsProfile);
    if (rawResponse.isSuccess && rawResponse.data.isNotEmpty) {
      final Map<String, dynamic>? rawPayload = _unwrapSinglePayload(
        rawResponse.data,
      );
      if (rawPayload != null && rawPayload.isNotEmpty) {
        return CareerProfileModel.fromApiJson(rawPayload);
      }
    }

    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('professional_profiles');
    if (response.isSuccess && response.data['success'] != false) {
      final Map<String, dynamic>? data = ApiPayloadReader.readMap(
        response.data['data'],
      );
      final Map<String, dynamic> resolved = data ?? response.data;
      if (resolved.isNotEmpty) {
        return CareerProfileModel.fromApiJson(resolved);
      }
    }

    return null;
  }

  Future<void> applyToJob(
    String jobId, {
    String coverLetter = '',
    String portfolioLink = '',
  }) async {
    await _service.apiClient.post(
      _service.endpoints['apply']!.replaceFirst(':id', jobId),
      <String, dynamic>{
        'coverLetter': coverLetter,
        'portfolioLink': portfolioLink,
      },
    );
  }

  Future<EmployerStatsModel?> employerStats() async {
    final Map<String, dynamic>? aggregatePayload =
        await _readAggregatePayload();
    final Map<String, dynamic>? aggregateStats = ApiPayloadReader.readMap(
      aggregatePayload?['employerStats'],
    );
    if (aggregateStats != null && aggregateStats.isNotEmpty) {
      return _employerStatsFromApiJson(aggregateStats);
    }

    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(ApiEndPoints.jobsEmployerStats);
    if (response.isSuccess && response.data.isNotEmpty) {
      final Map<String, dynamic>? payload = _unwrapSinglePayload(response.data);
      if (payload != null && payload.isNotEmpty) {
        return _employerStatsFromApiJson(payload);
      }
    }

    return null;
  }

  Future<EmployerProfileModel?> employerProfile() async {
    final Map<String, dynamic>? aggregatePayload =
        await _readAggregatePayload();
    final Map<String, dynamic>? aggregateProfile = ApiPayloadReader.readMap(
      aggregatePayload?['employerProfile'],
    );
    if (aggregateProfile != null && aggregateProfile.isNotEmpty) {
      return _employerProfileFromApiJson(aggregateProfile);
    }

    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(ApiEndPoints.jobsEmployerProfile);
    if (response.isSuccess && response.data.isNotEmpty) {
      final Map<String, dynamic>? payload = _unwrapSinglePayload(response.data);
      if (payload != null && payload.isNotEmpty) {
        return _employerProfileFromApiJson(payload);
      }
    }

    return null;
  }

  Future<bool> toggleSavedJob(String jobId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(ApiEndPoints.saveJob(jobId), const <String, dynamic>{});
    if (!response.isSuccess) {
      throw StateError('Unable to update saved jobs right now.');
    }
    final Map<String, dynamic>? payload = _unwrapSinglePayload(response.data);
    final bool? saved = ApiPayloadReader.readBool(payload?['saved']);
    if (saved == null) {
      throw StateError('Saved job response was empty.');
    }
    return saved;
  }

  Future<JobApplicationModel> withdrawApplication(String applicationId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(
          ApiEndPoints.withdrawJobApplication(applicationId),
          const <String, dynamic>{},
        );
    if (!response.isSuccess) {
      throw StateError('Unable to withdraw this application right now.');
    }
    final Map<String, dynamic>? payload = _unwrapSinglePayload(response.data);
    if (payload == null || payload.isEmpty) {
      throw StateError('Withdraw application response was empty.');
    }
    return _applicationFromApiJson(payload);
  }

  Future<bool> toggleCompanyFollow(String companyId, bool followed) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(ApiEndPoints.followJobCompany(companyId), <String, dynamic>{
          'followed': followed,
        });
    if (!response.isSuccess) {
      throw StateError('Unable to update company follow state right now.');
    }
    final Map<String, dynamic>? payload = _unwrapSinglePayload(response.data);
    final bool? nextFollowed = ApiPayloadReader.readBool(payload?['followed']);
    if (nextFollowed == null) {
      throw StateError('Company follow response was empty.');
    }
    return nextFollowed;
  }

  Future<JobAlertModel> createAlert({
    required String keyword,
    required String location,
    required AlertFrequency frequency,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(ApiEndPoints.jobsAlerts, <String, dynamic>{
          'keyword': keyword,
          'location': location,
          'frequency': frequency.name,
        });
    if (!response.isSuccess) {
      throw StateError('Unable to create this job alert right now.');
    }
    final Map<String, dynamic>? payload = _unwrapSinglePayload(response.data);
    if (payload == null || payload.isEmpty) {
      throw StateError('Job alert response was empty.');
    }
    return _alertFromApiJson(payload);
  }

  Future<JobAlertModel> toggleAlert(String alertId, bool enabled) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(ApiEndPoints.jobAlertById(alertId), <String, dynamic>{
          'enabled': enabled,
        });
    if (!response.isSuccess) {
      throw StateError('Unable to update this job alert right now.');
    }
    final Map<String, dynamic>? payload = _unwrapSinglePayload(response.data);
    if (payload == null || payload.isEmpty) {
      throw StateError('Job alert update response was empty.');
    }
    return _alertFromApiJson(payload);
  }

  Future<void> deleteMyJob(String jobId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .delete(ApiEndPoints.jobById(jobId));
    if (!response.isSuccess) {
      throw StateError('Unable to delete this job right now.');
    }
  }

  Future<ApplicantModel> updateApplicantStatus(
    String applicationId,
    ApplicationStatus status,
  ) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(
          ApiEndPoints.updateJobApplicationStatus(applicationId),
          <String, dynamic>{'status': _statusToApiValue(status)},
        );
    if (!response.isSuccess) {
      throw StateError('Unable to update applicant status right now.');
    }
    final Map<String, dynamic>? payload = _unwrapSinglePayload(response.data);
    if (payload == null || payload.isEmpty) {
      throw StateError('Applicant status response was empty.');
    }
    return _applicantFromApiJson(payload);
  }

  Future<List<ApplicantModel>> applicants() async {
    final List<Map<String, dynamic>> items = await _readJobList(
      aggregateKey: 'applicants',
      endpoint: ApiEndPoints.jobsApplicants,
      preferredKeys: const <String>['applicants'],
    );
    return items
        .map(_applicantFromApiJson)
        .where((ApplicantModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>?> _readAggregatePayload() async {
    if (_jobsNetworkingPayload != null && _jobsNetworkingPayload!.isNotEmpty) {
      return _jobsNetworkingPayload;
    }
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .apiClient
          .get(ApiEndPoints.jobsNetworking);
      if (!response.isSuccess || response.data.isEmpty) {
        return null;
      }
      _jobsNetworkingPayload =
          _unwrapSinglePayload(response.data) ?? response.data;
      return _jobsNetworkingPayload;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _readJobList({
    required String aggregateKey,
    required String endpoint,
    List<String> preferredKeys = const <String>[],
  }) async {
    final Map<String, dynamic>? aggregatePayload =
        await _readAggregatePayload();
    final List<Map<String, dynamic>> aggregateItems =
        ApiPayloadReader.readMapListFromAny(
          aggregatePayload?[aggregateKey],
          preferredKeys: preferredKeys,
        );
    if (aggregateItems.isNotEmpty) {
      return aggregateItems;
    }

    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .apiClient
          .get(endpoint);
      if (!response.isSuccess || response.data.isEmpty) {
        return const <Map<String, dynamic>>[];
      }
      final List<Map<String, dynamic>> items =
          ApiPayloadReader.readMapListFromAny(
            response.data,
            preferredKeys: preferredKeys,
          );
      if (items.isNotEmpty) {
        return items;
      }
      final Map<String, dynamic>? payload = _unwrapSinglePayload(response.data);
      if (payload != null && payload.isNotEmpty) {
        return ApiPayloadReader.readMapListFromAny(
          payload,
          preferredKeys: preferredKeys,
        );
      }
    } catch (_) {}

    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _unwrapSinglePayload(Map<String, dynamic> payload) {
    final Map<String, dynamic>? data = ApiPayloadReader.readMap(
      payload['data'],
    );
    final Map<String, dynamic>? result = ApiPayloadReader.readMap(
      payload['result'],
    );
    return data ?? result ?? payload;
  }

  JobApplicationModel _applicationFromApiJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: ApiPayloadReader.readString(json['id']),
      jobId: ApiPayloadReader.readString(json['jobId']),
      applicantName: ApiPayloadReader.readString(
        json['applicantName'],
        fallback: 'You',
      ),
      status: _applicationStatusFromValue(json['status']),
      appliedDate: ApiPayloadReader.readString(
        json['appliedDate'],
        fallback: 'Recently',
      ),
      timeline: ApiPayloadReader.readStringList(json['timeline']),
      coverLetter: ApiPayloadReader.readString(json['coverLetter']),
      portfolioLink: ApiPayloadReader.readString(json['portfolioLink']),
      resumeLabel: ApiPayloadReader.readString(
        json['resumeLabel'],
        fallback: 'Primary resume',
      ),
    );
  }

  JobAlertModel _alertFromApiJson(Map<String, dynamic> json) {
    return JobAlertModel(
      id: ApiPayloadReader.readString(json['id']),
      keyword: ApiPayloadReader.readString(json['keyword']),
      location: ApiPayloadReader.readString(json['location'], fallback: 'Any'),
      frequency: _alertFrequencyFromValue(json['frequency']),
      enabled: ApiPayloadReader.readBool(json['enabled']) ?? true,
    );
  }

  CompanyModel _companyFromApiJson(Map<String, dynamic> json) {
    final String name = ApiPayloadReader.readString(
      json['name'],
      fallback: 'Company',
    );
    return CompanyModel(
      id: ApiPayloadReader.readString(json['id']),
      name: name,
      tagline: ApiPayloadReader.readString(json['tagline']),
      logoInitial: name.isEmpty ? 'C' : name.substring(0, 1),
      colorValue: ApiPayloadReader.readInt(json['colorValue']),
      followers: ApiPayloadReader.readInt(json['followers']),
      followed: ApiPayloadReader.readBool(json['followed']) ?? false,
      verified: ApiPayloadReader.readBool(json['verified']) ?? false,
    );
  }

  EmployerStatsModel _employerStatsFromApiJson(Map<String, dynamic> json) {
    return EmployerStatsModel(
      totalJobs: ApiPayloadReader.readInt(json['totalJobs']),
      totalApplicants: ApiPayloadReader.readInt(json['totalApplicants']),
      shortlistedCandidates: ApiPayloadReader.readInt(
        json['shortlistedCandidates'],
      ),
      messages: ApiPayloadReader.readInt(json['messages']),
    );
  }

  EmployerProfileModel _employerProfileFromApiJson(Map<String, dynamic> json) {
    return EmployerProfileModel(
      companyName: ApiPayloadReader.readString(
        json['companyName'],
        fallback: '',
      ),
      hiringTitle: ApiPayloadReader.readString(json['hiringTitle']),
      about: ApiPayloadReader.readString(json['about']),
      location: ApiPayloadReader.readString(json['location']),
      hiringFocus: ApiPayloadReader.readStringList(json['hiringFocus']),
      openRoles: ApiPayloadReader.readStringList(json['openRoles']),
      teamHighlights: ApiPayloadReader.readStringList(json['teamHighlights']),
    );
  }

  ApplicantModel _applicantFromApiJson(Map<String, dynamic> json) {
    return ApplicantModel(
      id: ApiPayloadReader.readString(json['id']),
      name: ApiPayloadReader.readString(json['name']),
      title: ApiPayloadReader.readString(json['title']),
      skills: ApiPayloadReader.readStringList(json['skills']),
      status: _applicationStatusFromValue(json['status']),
      resumeLabel: ApiPayloadReader.readString(
        json['resumeLabel'],
        fallback: 'Primary resume',
      ),
    );
  }

  ApplicationStatus _applicationStatusFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'viewed':
        return ApplicationStatus.viewed;
      case 'shortlisted':
        return ApplicationStatus.shortlisted;
      case 'withdrawn':
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'pending':
      default:
        return ApplicationStatus.pending;
    }
  }

  AlertFrequency _alertFrequencyFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'instant':
        return AlertFrequency.instant;
      case 'weekly':
        return AlertFrequency.weekly;
      case 'daily':
      default:
        return AlertFrequency.daily;
    }
  }

  String _statusToApiValue(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'submitted';
      case ApplicationStatus.viewed:
        return 'viewed';
      case ApplicationStatus.shortlisted:
        return 'shortlisted';
      case ApplicationStatus.rejected:
        return 'rejected';
    }
  }
}
