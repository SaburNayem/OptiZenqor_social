import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/faq_item_model.dart';
import '../model/support_help_data_model.dart';
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
}
