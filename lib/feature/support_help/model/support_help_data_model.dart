import '../../../core/data/api/api_payload_reader.dart';
import 'faq_item_model.dart';
import 'support_ticket_summary_model.dart';

class SupportHelpDataModel {
  const SupportHelpDataModel({
    required this.faqs,
    required this.contactEmail,
    required this.escalationEmail,
    required this.responseTime,
    required this.ticketCount,
    required this.hasChatThread,
    required this.tickets,
    required this.loginHelpConfig,
  });

  final List<FaqItemModel> faqs;
  final String contactEmail;
  final String escalationEmail;
  final String responseTime;
  final int ticketCount;
  final bool hasChatThread;
  final List<SupportTicketSummaryModel> tickets;
  final LoginHelpConfigModel loginHelpConfig;
}

class LoginHelpConfigModel {
  const LoginHelpConfigModel({
    required this.enabled,
    required this.showOnLogin,
    required this.allowImages,
    required this.headerText,
    required this.bodyText,
  });

  factory LoginHelpConfigModel.fromApiJson(Map<String, dynamic>? json) {
    final Map<String, dynamic> payload = json ?? const <String, dynamic>{};
    return LoginHelpConfigModel(
      enabled: ApiPayloadReader.readBool(payload['enabled']) ?? true,
      showOnLogin: ApiPayloadReader.readBool(payload['showOnLogin']) ?? true,
      allowImages: ApiPayloadReader.readBool(payload['allowImages']) ?? true,
      headerText: ApiPayloadReader.readString(
        payload['headerText'],
        fallback: 'Need help signing in?',
      ),
      bodyText: ApiPayloadReader.readString(
        payload['bodyText'],
        fallback:
            'Send a message with an optional screenshot and support will reply from the admin dashboard.',
      ),
    );
  }

  static const LoginHelpConfigModel defaults = LoginHelpConfigModel(
    enabled: true,
    showOnLogin: true,
    allowImages: true,
    headerText: 'Need help signing in?',
    bodyText:
        'Send a message with an optional screenshot and support will reply from the admin dashboard.',
  );

  final bool enabled;
  final bool showOnLogin;
  final bool allowImages;
  final String headerText;
  final String bodyText;
}