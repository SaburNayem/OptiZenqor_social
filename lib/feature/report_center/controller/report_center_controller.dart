import 'package:flutter/foundation.dart';

import '../../../core/data/models/load_state_model.dart';
import '../model/report_item_model.dart';
import '../repository/report_center_repository.dart';

enum ReportHistoryFilter { all, open, closed }

class ReportCenterController extends ChangeNotifier {
  ReportCenterController({
    ReportCenterRepository? repository,
    ReportTargetDraft? initialTarget,
  }) : _repository = repository ?? ReportCenterRepository(),
       _initialTarget = initialTarget;

  final ReportCenterRepository _repository;
  final ReportTargetDraft? _initialTarget;

  LoadStateModel state = const LoadStateModel();
  ReportCenterSummary summary = const ReportCenterSummary();
  List<ReportTargetOptionModel> targetOptions = <ReportTargetOptionModel>[];
  List<ReportReasonOptionModel> reasonOptions = <ReportReasonOptionModel>[];
  List<ReportStatusOptionModel> statusOptions = <ReportStatusOptionModel>[];
  List<ReportItemModel> history = <ReportItemModel>[];
  ReportTargetOptionModel? selectedTargetType;
  ReportReasonOptionModel? selectedReason;
  ReportHistoryFilter historyFilter = ReportHistoryFilter.all;
  bool isSubmitting = false;
  String targetId = '';
  String targetUserId = '';
  String targetLabel = '';
  String targetSubtitle = '';
  String targetPreviewImageUrl = '';
  String details = '';
  String? submitMessage;

  bool get hasPrefilledTarget => _initialTarget?.hasTarget == true;

  List<ReportReasonOptionModel> get visibleReasons {
    final String key = selectedTargetType?.key ?? '';
    return reasonOptions
        .where((ReportReasonOptionModel option) => option.appliesToTarget(key))
        .toList(growable: false);
  }

  List<ReportItemModel> get visibleHistory {
    switch (historyFilter) {
      case ReportHistoryFilter.all:
        return history;
      case ReportHistoryFilter.open:
        return history.where((ReportItemModel item) => item.isOpen).toList();
      case ReportHistoryFilter.closed:
        return history.where((ReportItemModel item) => !item.isOpen).toList();
    }
  }

  bool get canSubmit {
    return !isSubmitting &&
        selectedTargetType != null &&
        selectedReason != null &&
        targetId.trim().isNotEmpty;
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );
    notifyListeners();
    try {
      final ReportCenterPayload payload = await _repository.fetchReportCenter();
      summary = payload.summary;
      history = payload.reports;
      _applyOptions(payload.options);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        isEmpty: history.isEmpty,
        hasError: false,
        errorMessage: null,
      );
      notifyListeners();
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
      notifyListeners();
      await _loadOptionsFallback();
    }
  }

  Future<void> refresh() => load();

  void selectTargetType(ReportTargetOptionModel option) {
    selectedTargetType = option;
    if (selectedReason != null &&
        !selectedReason!.appliesToTarget(option.key)) {
      selectedReason = null;
    }
    submitMessage = null;
    notifyListeners();
  }

  void selectReason(ReportReasonOptionModel option) {
    selectedReason = option;
    submitMessage = null;
    notifyListeners();
  }

  void setHistoryFilter(ReportHistoryFilter filter) {
    historyFilter = filter;
    notifyListeners();
  }

  void updateTargetId(String value) {
    final String nextTargetId = value.trim();
    targetId = nextTargetId;
    if (selectedTargetType?.key == 'user') {
      targetUserId = nextTargetId;
    }
    submitMessage = null;
    notifyListeners();
  }

  void updateDetails(String value) {
    details = value;
    submitMessage = null;
  }

  Future<bool> submit() async {
    final ReportTargetOptionModel? targetType = selectedTargetType;
    final ReportReasonOptionModel? reason = selectedReason;
    if (targetType == null || reason == null || targetId.trim().isEmpty) {
      submitMessage = 'Choose what happened and the item you want reviewed.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    submitMessage = null;
    notifyListeners();
    try {
      final ReportItemModel created = await _repository.submitReport(
        targetType: targetType.key,
        targetId: targetId,
        targetUserId: targetUserId,
        reason: reason.key,
        details: details,
      );
      history = <ReportItemModel>[
        created,
        ...history.where((ReportItemModel item) => item.id != created.id),
      ];
      summary = ReportCenterSummary(
        total: summary.total + 1,
        openReports: summary.openReports + 1,
        resolvedReports: summary.resolvedReports,
        byStatus: <String, int>{
          ...summary.byStatus,
          created.status: (summary.byStatus[created.status] ?? 0) + 1,
        },
        byTargetType: <String, int>{
          ...summary.byTargetType,
          created.targetType:
              (summary.byTargetType[created.targetType] ?? 0) + 1,
        },
      );
      selectedReason = null;
      details = '';
      isSubmitting = false;
      submitMessage = 'Report sent. Moderators can now review this.';
      state = state.copyWith(
        isSuccess: true,
        isEmpty: history.isEmpty,
        hasError: false,
        errorMessage: null,
      );
      notifyListeners();
      return true;
    } catch (error) {
      isSubmitting = false;
      submitMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadOptionsFallback() async {
    try {
      final ReportOptionsModel options = await _repository.fetchOptions();
      _applyOptions(options);
      state = state.copyWith(isLoading: false);
      notifyListeners();
    } catch (_) {}
  }

  void _applyOptions(ReportOptionsModel options) {
    targetOptions = options.targetTypes;
    reasonOptions = options.reasons;
    statusOptions = options.statuses;
    _applyInitialTarget();
  }

  void _applyInitialTarget() {
    final ReportTargetDraft? initial = _initialTarget;
    if (initial == null || !initial.hasTarget) {
      return;
    }
    targetId = initial.targetId;
    targetUserId = initial.targetUserId ?? '';
    targetLabel = initial.label ?? '';
    targetSubtitle = initial.subtitle ?? '';
    targetPreviewImageUrl = initial.previewImageUrl ?? '';
    selectedTargetType = _findTargetOption(initial.targetType);
  }

  ReportTargetOptionModel? _findTargetOption(String targetType) {
    for (final ReportTargetOptionModel option in targetOptions) {
      if (option.matches(targetType)) {
        return option;
      }
    }
    return null;
  }
}
