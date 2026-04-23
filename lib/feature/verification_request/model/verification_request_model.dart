import '../../../core/data/api/api_payload_reader.dart';

enum VerificationStatus { notRequested, pending, approved, rejected }

class VerificationRequestModel {
  const VerificationRequestModel({
    required this.status,
    required this.reason,
    required this.selectedDocuments,
    this.requiredDocuments = const <String>[],
    this.submittedAt,
  });

  final VerificationStatus status;
  final String reason;
  final List<String> selectedDocuments;
  final List<String> requiredDocuments;
  final DateTime? submittedAt;

  VerificationRequestModel copyWith({
    VerificationStatus? status,
    String? reason,
    List<String>? selectedDocuments,
    List<String>? requiredDocuments,
    DateTime? submittedAt,
    bool clearSubmittedAt = false,
  }) {
    return VerificationRequestModel(
      status: status ?? this.status,
      reason: reason ?? this.reason,
      selectedDocuments: selectedDocuments ?? this.selectedDocuments,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      submittedAt: clearSubmittedAt ? null : submittedAt ?? this.submittedAt,
    );
  }

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    return VerificationRequestModel(
      status: VerificationStatus.values.firstWhere(
        (item) =>
            item.name ==
            ApiPayloadReader.readString(
              json['status'],
              fallback: VerificationStatus.notRequested.name,
            ),
        orElse: () => VerificationStatus.notRequested,
      ),
      reason: json['reason'] as String? ?? 'Not submitted',
      selectedDocuments: List<String>.from(
        json['selectedDocuments'] as List<dynamic>? ?? const <dynamic>[],
      ),
      requiredDocuments: List<String>.from(
        json['requiredDocuments'] as List<dynamic>? ?? const <dynamic>[],
      ),
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.tryParse(json['submittedAt'] as String),
    );
  }

  factory VerificationRequestModel.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        ApiPayloadReader.readMap(json['data']) ??
        ApiPayloadReader.readMap(json['result']) ??
        json;

    return VerificationRequestModel(
      status: VerificationStatus.values.firstWhere(
        (VerificationStatus item) =>
            item.name ==
            ApiPayloadReader.readString(
              data['status'],
              fallback: VerificationStatus.notRequested.name,
            ),
        orElse: () => VerificationStatus.notRequested,
      ),
      reason: ApiPayloadReader.readString(
        data['reason'] ?? data['message'],
        fallback: 'Not submitted',
      ),
      selectedDocuments: ApiPayloadReader.readStringList(
        data['selectedDocuments'] ?? data['documents'],
      ),
      requiredDocuments: ApiPayloadReader.readStringList(
        data['requiredDocuments'] ?? json['requiredDocuments'],
      ),
      submittedAt: ApiPayloadReader.readDateTime(data['submittedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status.name,
      'reason': reason,
      'selectedDocuments': selectedDocuments,
      'requiredDocuments': requiredDocuments,
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }
}
