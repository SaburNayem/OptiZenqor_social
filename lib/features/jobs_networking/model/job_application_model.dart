import 'job_model.dart';

class JobApplicationModel {
  const JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.applicantName,
    required this.status,
    required this.appliedDate,
    required this.timeline,
    this.coverLetter = '',
    this.portfolioLink = '',
    this.resumeLabel = 'Primary resume',
  });

  final String id;
  final String jobId;
  final String applicantName;
  final ApplicationStatus status;
  final String appliedDate;
  final List<String> timeline;
  final String coverLetter;
  final String portfolioLink;
  final String resumeLabel;

  JobApplicationModel copyWith({
    ApplicationStatus? status,
    String? coverLetter,
    String? portfolioLink,
    String? resumeLabel,
  }) {
    return JobApplicationModel(
      id: id,
      jobId: jobId,
      applicantName: applicantName,
      status: status ?? this.status,
      appliedDate: appliedDate,
      timeline: timeline,
      coverLetter: coverLetter ?? this.coverLetter,
      portfolioLink: portfolioLink ?? this.portfolioLink,
      resumeLabel: resumeLabel ?? this.resumeLabel,
    );
  }
}

class ApplicantModel {
  const ApplicantModel({
    required this.id,
    required this.name,
    required this.title,
    required this.skills,
    required this.status,
    required this.resumeLabel,
  });

  final String id;
  final String name;
  final String title;
  final List<String> skills;
  final ApplicationStatus status;
  final String resumeLabel;

  ApplicantModel copyWith({ApplicationStatus? status}) {
    return ApplicantModel(
      id: id,
      name: name,
      title: title,
      skills: skills,
      status: status ?? this.status,
      resumeLabel: resumeLabel,
    );
  }
}
