import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/report_item_model.dart';
import '../service/report_center_service.dart';

class ReportCenterRepository {
  ReportCenterRepository({ReportCenterService? service})
    : _service = service ?? ReportCenterService();

  final ReportCenterService _service;

  Future<ReportCenterPayload> fetchReportCenter() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('report_center');
    _ensureSuccess(response, fallback: 'Unable to load report center.');
    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Report center response did not include data.',
    );
    ReportCenterPayload payload = ReportCenterPayload.fromApiJson(data);
    if (payload.options.targetTypes.isEmpty ||
        payload.options.reasons.isEmpty) {
      final ReportOptionsModel options = await fetchOptions();
      payload = ReportCenterPayload(
        summary: payload.summary,
        reports: payload.reports,
        options: options,
      );
    }
    return payload;
  }

  Future<ReportOptionsModel> fetchOptions() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('report_options');
    _ensureSuccess(response, fallback: 'Unable to load report options.');
    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Report options response did not include data.',
    );
    return ReportOptionsModel.fromApiJson(data);
  }

  Future<ReportItemModel> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? targetUserId,
    String? details,
  }) async {
    final String normalizedTargetType = normalizeReportKey(targetType);
    final String trimmedTargetId = targetId.trim();
    final Map<String, dynamic> payload = <String, dynamic>{
      'reason': reason,
      'targetType': normalizedTargetType,
      'targetId': trimmedTargetId,
      'targetEntityType': normalizedTargetType,
      if (normalizedTargetType == 'user')
        'targetUserId': targetUserId?.trim().isNotEmpty == true
            ? targetUserId!.trim()
            : trimmedTargetId
      else ...<String, dynamic>{
        'targetEntityId': trimmedTargetId,
        if (targetUserId?.trim().isNotEmpty == true)
          'targetUserId': targetUserId!.trim(),
      },
      if (details?.trim().isNotEmpty == true) 'details': details!.trim(),
    };
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .postEndpoint('report_center', payload: payload);
    _ensureSuccess(response, fallback: 'Unable to submit report.');
    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Submit report response did not include data.',
    );
    return ReportItemModel.fromApiJson(data);
  }

  void _ensureSuccess(
    ServiceResponseModel<Map<String, dynamic>> response, {
    required String fallback,
  }) {
    if (response.isSuccess && response.data['success'] != false) {
      return;
    }
    throw Exception(response.message ?? response.data['message'] ?? fallback);
  }
}
