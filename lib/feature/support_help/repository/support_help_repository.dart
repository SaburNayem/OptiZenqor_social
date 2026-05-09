import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/faq_item_model.dart';
import '../model/support_help_data_model.dart';
import '../model/support_ticket_detail_model.dart';
import '../model/support_ticket_summary_model.dart';
import '../service/support_help_service.dart';

class SupportHelpRepository {
  SupportHelpRepository({SupportHelpService? service})
    : _service = service ?? SupportHelpService();

  final SupportHelpService _service;

  Future<SupportHelpDataModel> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('support_help');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(
        response.data['message']?.toString() ?? 'Failed to load support help.',
      );
    }

    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response.data['data']) ?? response.data;
    final List<FaqItemModel> faqs = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['faqs'],
    ).map(FaqItemModel.fromApiJson).toList(growable: false);

    final Map<String, dynamic> mail =
        ApiPayloadReader.readMap(payload['mail']) ?? const <String, dynamic>{};
    final List<Map<String, dynamic>> tickets = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['tickets'],
    );
    final List<SupportTicketSummaryModel> ticketModels = tickets
        .map(SupportTicketSummaryModel.fromApiJson)
        .where((SupportTicketSummaryModel item) => item.id.isNotEmpty)
        .toList(growable: false);
    final Map<String, dynamic> chat =
        ApiPayloadReader.readMap(payload['chat']) ?? const <String, dynamic>{};

    return SupportHelpDataModel(
      faqs: faqs,
      contactEmail: ApiPayloadReader.readString(mail['contactEmail']),
      escalationEmail: ApiPayloadReader.readString(mail['escalationEmail']),
      responseTime: ApiPayloadReader.readString(mail['responseTime']),
      ticketCount: ticketModels.length,
      hasChatThread:
          ApiPayloadReader.readString(chat['threadId']).isNotEmpty ||
          ApiPayloadReader.readString(chat['conversationId']).isNotEmpty,
      tickets: ticketModels,
    );
  }

  Future<SupportTicketDetailModel> loadTicket(String ticketId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getTicket(ticketId);
    return _readTicketDetail(
      response,
      fallbackMessage: 'Failed to load support ticket.',
    );
  }

  Future<SupportTicketSummaryModel> createTicket({
    required String subject,
    required String category,
    required String message,
    String priority = 'normal',
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .createTicket(<String, dynamic>{
          'subject': subject,
          'category': category,
          'message': message,
          'priority': priority,
        });
    return _readTicketSummary(
      response,
      fallbackMessage: 'Failed to create support ticket.',
    );
  }

  Future<SupportTicketDetailModel> sendTicketMessage({
    required String ticketId,
    required String message,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .sendTicketMessage(ticketId, <String, dynamic>{'message': message});
    return _readTicketDetail(
      response,
      fallbackMessage: 'Failed to send support message.',
    );
  }

  Future<SupportTicketDetailModel> updateTicket({
    required String ticketId,
    String? subject,
    String? category,
    String? status,
    String? priority,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{};
    if (subject != null && subject.trim().isNotEmpty) {
      payload['subject'] = subject.trim();
    }
    if (category != null && category.trim().isNotEmpty) {
      payload['category'] = category.trim();
    }
    if (status != null && status.trim().isNotEmpty) {
      payload['status'] = status.trim();
    }
    if (priority != null && priority.trim().isNotEmpty) {
      payload['priority'] = priority.trim();
    }
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .updateTicket(ticketId, payload);
    return _readTicketDetail(
      response,
      fallbackMessage: 'Failed to update support ticket.',
    );
  }

  SupportTicketSummaryModel _readTicketSummary(
    ServiceResponseModel<Map<String, dynamic>> response, {
    required String fallbackMessage,
  }) {
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.data['message']?.toString() ?? fallbackMessage);
    }

    final Map<String, dynamic>? payload = _readPayloadMap(response.data);
    if (payload == null) {
      throw Exception(fallbackMessage);
    }
    return SupportTicketSummaryModel.fromApiJson(payload);
  }

  SupportTicketDetailModel _readTicketDetail(
    ServiceResponseModel<Map<String, dynamic>> response, {
    required String fallbackMessage,
  }) {
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.data['message']?.toString() ?? fallbackMessage);
    }

    final Map<String, dynamic>? payload = _readPayloadMap(response.data);
    if (payload == null) {
      throw Exception(fallbackMessage);
    }
    return SupportTicketDetailModel.fromApiJson(payload);
  }

  Map<String, dynamic>? _readPayloadMap(Map<String, dynamic> payload) {
    return ApiPayloadReader.readMap(payload['data']) ??
        ApiPayloadReader.readMap(payload['ticket']) ??
        ApiPayloadReader.readMap(payload);
  }
}
