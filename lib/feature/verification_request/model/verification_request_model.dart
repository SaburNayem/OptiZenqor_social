enum VerificationStatus { notRequested, pending, approved, rejected }

class VerificationRequestModel {
  const VerificationRequestModel({
    required this.status,
    required this.reason,
    required this.selectedDocuments,
    this.submittedAt,
  });

  final VerificationStatus status;
  final String reason;
  final List<String> selectedDocuments;
  final DateTime? submittedAt;

  VerificationRequestModel copyWith({
    VerificationStatus? status,
    String? reason,
    List<String>? selectedDocuments,
    DateTime? submittedAt,
    bool clearSubmittedAt = false,
  }) {
    return VerificationRequestModel(
      status: status ?? this.status,
      reason: reason ?? this.reason,
      selectedDocuments: selectedDocuments ?? this.selectedDocuments,
      submittedAt: clearSubmittedAt ? null : submittedAt ?? this.submittedAt,
    );
  }

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    return VerificationRequestModel(
      status: VerificationStatus.values.firstWhere(
        (item) => item.name == json['status'],
        orElse: () => VerificationStatus.notRequested,
      ),
      reason: json['reason'] as String? ?? 'Not submitted',
      selectedDocuments: List<String>.from(
        json['selectedDocuments'] as List<dynamic>? ?? const <dynamic>[],
      ),
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.tryParse(json['submittedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status.name,
      'reason': reason,
      'selectedDocuments': selectedDocuments,
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }
}
