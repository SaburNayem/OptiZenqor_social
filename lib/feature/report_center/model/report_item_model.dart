import '../../../core/data/api/api_payload_reader.dart';

class ReportTargetDraft {
  const ReportTargetDraft({
    required this.targetType,
    required this.targetId,
    this.targetUserId,
    this.label,
    this.subtitle,
    this.previewImageUrl,
  });

  factory ReportTargetDraft.fromArguments(Object? arguments) {
    if (arguments is ReportTargetDraft) {
      return arguments;
    }
    if (arguments is Map<String, dynamic>) {
      return ReportTargetDraft.fromMap(arguments);
    }
    if (arguments is Map) {
      return ReportTargetDraft.fromMap(Map<String, dynamic>.from(arguments));
    }
    return const ReportTargetDraft(targetType: '', targetId: '');
  }

  factory ReportTargetDraft.fromMap(Map<String, dynamic> map) {
    final String targetType = ApiPayloadReader.readString(
      map['targetType'] ?? map['targetEntityType'] ?? map['type'],
    );
    final String targetId = ApiPayloadReader.readString(
      map['targetId'] ?? map['targetEntityId'] ?? map['id'],
    );
    return ReportTargetDraft(
      targetType: targetType,
      targetId: targetId,
      targetUserId: ApiPayloadReader.readString(map['targetUserId']),
      label: ApiPayloadReader.readString(
        map['label'] ?? map['targetLabel'] ?? map['title'],
      ),
      subtitle: ApiPayloadReader.readString(
        map['subtitle'] ?? map['targetSubtitle'] ?? map['summary'],
      ),
      previewImageUrl: ApiPayloadReader.readString(
        map['previewImageUrl'] ?? map['imageUrl'] ?? map['thumbnailUrl'],
      ),
    );
  }

  final String targetType;
  final String targetId;
  final String? targetUserId;
  final String? label;
  final String? subtitle;
  final String? previewImageUrl;

  bool get hasTarget =>
      targetType.trim().isNotEmpty && targetId.trim().isNotEmpty;
}

class ReportCenterPayload {
  const ReportCenterPayload({
    required this.summary,
    required this.reports,
    required this.options,
  });

  factory ReportCenterPayload.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic> options =
        ApiPayloadReader.readMap(json['options']) ?? const <String, dynamic>{};
    final List<Map<String, dynamic>> reports = ApiPayloadReader.readMapList(
      json,
      preferredKeys: const <String>['reports'],
    );
    return ReportCenterPayload(
      summary: ReportCenterSummary.fromApiJson(
        ApiPayloadReader.readMap(json['summary']) ?? const <String, dynamic>{},
      ),
      reports: reports.map(ReportItemModel.fromApiJson).toList(growable: false),
      options: ReportOptionsModel.fromApiJson(options),
    );
  }

  final ReportCenterSummary summary;
  final List<ReportItemModel> reports;
  final ReportOptionsModel options;
}

class ReportCenterSummary {
  const ReportCenterSummary({
    this.total = 0,
    this.openReports = 0,
    this.resolvedReports = 0,
    this.byStatus = const <String, int>{},
    this.byTargetType = const <String, int>{},
  });

  factory ReportCenterSummary.fromApiJson(Map<String, dynamic> json) {
    return ReportCenterSummary(
      total: ApiPayloadReader.readInt(json['total']),
      openReports: ApiPayloadReader.readInt(json['openReports']),
      resolvedReports: ApiPayloadReader.readInt(json['resolvedReports']),
      byStatus: _readCountMap(json['byStatus']),
      byTargetType: _readCountMap(json['byTargetType']),
    );
  }

  final int total;
  final int openReports;
  final int resolvedReports;
  final Map<String, int> byStatus;
  final Map<String, int> byTargetType;

  static Map<String, int> _readCountMap(Object? value) {
    final Map<String, dynamic>? map = ApiPayloadReader.readMap(value);
    if (map == null) {
      return const <String, int>{};
    }
    return map.map((String key, dynamic value) {
      return MapEntry(key, ApiPayloadReader.readInt(value));
    });
  }
}

class ReportOptionsModel {
  const ReportOptionsModel({
    this.targetTypes = const <ReportTargetOptionModel>[],
    this.reasons = const <ReportReasonOptionModel>[],
    this.statuses = const <ReportStatusOptionModel>[],
  });

  factory ReportOptionsModel.fromApiJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> targets =
        ApiPayloadReader.readMapListFromAny(json['targetTypes']);
    final List<Map<String, dynamic>> reasons =
        ApiPayloadReader.readMapListFromAny(json['reasons']);
    final List<Map<String, dynamic>> statuses =
        ApiPayloadReader.readMapListFromAny(json['statuses']);
    return ReportOptionsModel(
      targetTypes: targets
          .map(ReportTargetOptionModel.fromApiJson)
          .where((ReportTargetOptionModel item) => item.key.isNotEmpty)
          .toList(growable: false),
      reasons: reasons
          .map(ReportReasonOptionModel.fromApiJson)
          .where((ReportReasonOptionModel item) => item.key.isNotEmpty)
          .toList(growable: false),
      statuses: statuses
          .map(ReportStatusOptionModel.fromApiJson)
          .where((ReportStatusOptionModel item) => item.key.isNotEmpty)
          .toList(growable: false),
    );
  }

  final List<ReportTargetOptionModel> targetTypes;
  final List<ReportReasonOptionModel> reasons;
  final List<ReportStatusOptionModel> statuses;
}

class ReportTargetOptionModel {
  const ReportTargetOptionModel({
    required this.key,
    required this.label,
    required this.description,
    this.adminSection = '',
    this.routeName = '',
    this.actionLabel = '',
    this.aliases = const <String>[],
  });

  factory ReportTargetOptionModel.fromApiJson(Map<String, dynamic> json) {
    return ReportTargetOptionModel(
      key: ApiPayloadReader.readString(json['key']),
      label: ApiPayloadReader.readString(json['label']),
      description: ApiPayloadReader.readString(json['description']),
      adminSection: ApiPayloadReader.readString(json['adminSection']),
      routeName: ApiPayloadReader.readString(json['routeName']),
      actionLabel: ApiPayloadReader.readString(json['actionLabel']),
      aliases: ApiPayloadReader.readStringList(json['aliases']),
    );
  }

  final String key;
  final String label;
  final String description;
  final String adminSection;
  final String routeName;
  final String actionLabel;
  final List<String> aliases;

  bool matches(String value) {
    final String normalized = normalizeReportKey(value);
    return key == normalized ||
        aliases.map(normalizeReportKey).contains(normalized);
  }
}

class ReportReasonOptionModel {
  const ReportReasonOptionModel({
    required this.key,
    required this.label,
    required this.description,
    required this.severity,
    required this.appliesTo,
  });

  factory ReportReasonOptionModel.fromApiJson(Map<String, dynamic> json) {
    return ReportReasonOptionModel(
      key: ApiPayloadReader.readString(json['key']),
      label: ApiPayloadReader.readString(json['label']),
      description: ApiPayloadReader.readString(json['description']),
      severity: ApiPayloadReader.readString(
        json['severity'],
        fallback: 'medium',
      ),
      appliesTo: ApiPayloadReader.readStringList(json['appliesTo']),
    );
  }

  final String key;
  final String label;
  final String description;
  final String severity;
  final List<String> appliesTo;

  bool appliesToTarget(String targetType) {
    if (targetType.trim().isEmpty) {
      return true;
    }
    final String normalized = normalizeReportKey(targetType);
    return appliesTo.any((String value) {
      final String candidate = normalizeReportKey(value);
      return candidate == 'all' || candidate == normalized;
    });
  }
}

class ReportStatusOptionModel {
  const ReportStatusOptionModel({
    required this.key,
    required this.label,
    required this.description,
  });

  factory ReportStatusOptionModel.fromApiJson(Map<String, dynamic> json) {
    return ReportStatusOptionModel(
      key: ApiPayloadReader.readString(json['key']),
      label: ApiPayloadReader.readString(json['label']),
      description: ApiPayloadReader.readString(json['description']),
    );
  }

  final String key;
  final String label;
  final String description;
}

class ReportItemModel {
  const ReportItemModel({
    required this.id,
    required this.reason,
    required this.reasonLabel,
    required this.reasonDescription,
    required this.status,
    required this.statusLabel,
    required this.statusDescription,
    required this.severity,
    required this.targetType,
    required this.targetTypeLabel,
    required this.targetId,
    required this.targetLabel,
    required this.displayTitle,
    this.targetSummary,
    this.targetOwnerName,
    this.details,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportItemModel.fromApiJson(Map<String, dynamic> json) {
    final String reason = ApiPayloadReader.readString(json['reason']);
    final String status = ApiPayloadReader.readString(
      json['status'],
      fallback: 'submitted',
    );
    final String targetType = ApiPayloadReader.readString(
      json['targetType'] ?? json['targetEntityType'],
    );
    final String targetLabel = ApiPayloadReader.readString(
      json['targetLabel'] ?? json['targetId'] ?? json['targetEntityId'],
    );
    return ReportItemModel(
      id: ApiPayloadReader.readString(json['id']),
      reason: reason,
      reasonLabel: ApiPayloadReader.readString(
        json['reasonLabel'],
        fallback: _labelize(reason),
      ),
      reasonDescription: ApiPayloadReader.readString(json['reasonDescription']),
      status: status,
      statusLabel: ApiPayloadReader.readString(
        json['statusLabel'],
        fallback: _labelize(status),
      ),
      statusDescription: ApiPayloadReader.readString(json['statusDescription']),
      severity: ApiPayloadReader.readString(
        json['severity'],
        fallback: 'medium',
      ),
      targetType: targetType,
      targetTypeLabel: ApiPayloadReader.readString(
        json['targetTypeLabel'],
        fallback: _labelize(targetType),
      ),
      targetId: ApiPayloadReader.readString(
        json['targetId'] ?? json['targetEntityId'] ?? json['targetUserId'],
      ),
      targetLabel: targetLabel,
      targetSummary: ApiPayloadReader.readString(json['targetSummary']),
      targetOwnerName: ApiPayloadReader.readString(json['targetOwnerName']),
      details: ApiPayloadReader.readString(json['details']),
      displayTitle: ApiPayloadReader.readString(
        json['displayTitle'],
        fallback: '${_labelize(reason)} on ${_labelize(targetType)}',
      ),
      createdAt: ApiPayloadReader.readDateTime(json['createdAt']),
      updatedAt: ApiPayloadReader.readDateTime(json['updatedAt']),
    );
  }

  final String id;
  final String reason;
  final String reasonLabel;
  final String reasonDescription;
  final String status;
  final String statusLabel;
  final String statusDescription;
  final String severity;
  final String targetType;
  final String targetTypeLabel;
  final String targetId;
  final String targetLabel;
  final String displayTitle;
  final String? targetSummary;
  final String? targetOwnerName;
  final String? details;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isOpen => status != 'resolved' && status != 'rejected';
}

String normalizeReportKey(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[\s-]+'), '_')
      .replaceAll(RegExp(r'[^a-z0-9_]'), '')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

String _labelize(String value) {
  final String normalized = value.replaceAll(RegExp(r'[-_]+'), ' ').trim();
  if (normalized.isEmpty) {
    return 'Report';
  }
  return normalized
      .split(' ')
      .where((String part) => part.isNotEmpty)
      .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
