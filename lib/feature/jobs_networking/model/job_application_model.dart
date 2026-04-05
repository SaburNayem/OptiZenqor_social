class JobApplicationModel {
  const JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.applicantName,
    required this.status,
  });

  final String id;
  final String jobId;
  final String applicantName;
  final String status;
}
