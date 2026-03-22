enum VerificationStatus { notRequested, pending, approved, rejected }

class VerificationRequestModel {
  const VerificationRequestModel({required this.status, required this.reason});

  final VerificationStatus status;
  final String reason;
}
