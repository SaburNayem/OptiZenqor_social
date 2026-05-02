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
  });

  final List<FaqItemModel> faqs;
  final String contactEmail;
  final String escalationEmail;
  final String responseTime;
  final int ticketCount;
  final bool hasChatThread;
  final List<SupportTicketSummaryModel> tickets;
}
