import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';
import '../../../core/data/service_model/service_response_model.dart';

class SupportHelpService extends FeatureServiceBase {
  SupportHelpService({super.apiClient});

  @override
  String get featureName => 'support_help';

  @override
  Map<String, String> get endpoints => <String, String>{
    'support_help': ApiEndPoints.supportHelp,
    'faq': ApiEndPoints.supportHelpFaq,
    'mail': ApiEndPoints.supportHelpMail,
    'faqs': ApiEndPoints.supportFaqs,
    'tickets': ApiEndPoints.supportTickets,
    'chat': ApiEndPoints.supportHelpChat,
  };

  Future<ServiceResponseModel<Map<String, dynamic>>> getTicket(
    String ticketId,
  ) {
    return apiClient.get(ApiEndPoints.supportTicketById(ticketId));
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> createTicket(
    Map<String, dynamic> payload,
  ) {
    return apiClient.post(ApiEndPoints.supportTickets, payload);
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> sendTicketMessage(
    String ticketId,
    Map<String, dynamic> payload,
  ) {
    return apiClient.post(
      ApiEndPoints.supportTicketMessages(ticketId),
      payload,
    );
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> updateTicket(
    String ticketId,
    Map<String, dynamic> payload,
  ) {
    return apiClient.patch(ApiEndPoints.supportTicketById(ticketId), payload);
  }
}
