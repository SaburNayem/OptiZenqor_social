import 'package:flutter/foundation.dart';

import '../model/faq_item_model.dart';
import '../model/support_help_data_model.dart';
import '../model/support_ticket_detail_model.dart';
import '../model/support_ticket_summary_model.dart';
import '../repository/support_help_repository.dart';

class SupportHelpController extends ChangeNotifier {
  SupportHelpController({SupportHelpRepository? repository})
    : _repository = repository ?? SupportHelpRepository();

  final SupportHelpRepository _repository;
  List<FaqItemModel> faqs = <FaqItemModel>[];
  String contactEmail = '';
  String escalationEmail = '';
  String responseTime = '';
  int ticketCount = 0;
  bool hasChatThread = false;
  List<SupportTicketSummaryModel> tickets = <SupportTicketSummaryModel>[];
  bool isLoading = false;
  bool isDetailLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  String? actionMessage;
  String? selectedTicketId;
  SupportTicketDetailModel? selectedTicket;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final SupportHelpDataModel data = await _repository.load();
      faqs = data.faqs;
      contactEmail = data.contactEmail;
      escalationEmail = data.escalationEmail;
      responseTime = data.responseTime;
      ticketCount = data.ticketCount;
      hasChatThread = data.hasChatThread;
      tickets = data.tickets;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      faqs = <FaqItemModel>[];
      tickets = <SupportTicketSummaryModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openTicket(String ticketId) async {
    selectedTicketId = ticketId;
    isDetailLoading = true;
    actionMessage = null;
    notifyListeners();

    try {
      selectedTicket = await _repository.loadTicket(ticketId);
    } catch (error) {
      actionMessage = error.toString().replaceFirst('Exception: ', '');
      selectedTicket = null;
    } finally {
      isDetailLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedTicket() {
    selectedTicketId = null;
    selectedTicket = null;
    actionMessage = null;
    isDetailLoading = false;
    notifyListeners();
  }

  Future<bool> createTicket({
    required String subject,
    required String category,
    required String message,
    String priority = 'normal',
  }) async {
    isSubmitting = true;
    actionMessage = null;
    notifyListeners();

    try {
      final SupportTicketSummaryModel created = await _repository.createTicket(
        subject: subject,
        category: category,
        message: message,
        priority: priority,
      );
      tickets = <SupportTicketSummaryModel>[created, ...tickets];
      ticketCount = tickets.length;
      hasChatThread = true;
      actionMessage = 'Support ticket created successfully.';
      await openTicket(created.id);
      return true;
    } catch (error) {
      actionMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> sendReply(String message) async {
    final String ticketId =
        selectedTicketId ?? selectedTicket?.summary.id ?? '';
    if (ticketId.isEmpty) {
      actionMessage = 'Select a support ticket first.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    actionMessage = null;
    notifyListeners();

    try {
      final SupportTicketDetailModel detail = await _repository
          .sendTicketMessage(ticketId: ticketId, message: message);
      _applyTicketDetail(detail);
      actionMessage = 'Reply sent successfully.';
      return true;
    } catch (error) {
      actionMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateSelectedTicket({
    String? status,
    String? priority,
    String? subject,
    String? category,
  }) async {
    final String ticketId =
        selectedTicketId ?? selectedTicket?.summary.id ?? '';
    if (ticketId.isEmpty) {
      actionMessage = 'Select a support ticket first.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    actionMessage = null;
    notifyListeners();

    try {
      final SupportTicketDetailModel detail = await _repository.updateTicket(
        ticketId: ticketId,
        status: status,
        priority: priority,
        subject: subject,
        category: category,
      );
      _applyTicketDetail(detail);
      actionMessage = 'Support ticket updated successfully.';
      return true;
    } catch (error) {
      actionMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void consumeActionMessage() {
    actionMessage = null;
  }

  void _applyTicketDetail(SupportTicketDetailModel detail) {
    selectedTicketId = detail.summary.id;
    selectedTicket = detail;
    final int index = tickets.indexWhere(
      (SupportTicketSummaryModel item) => item.id == detail.summary.id,
    );
    if (index == -1) {
      tickets = <SupportTicketSummaryModel>[detail.summary, ...tickets];
    } else {
      final List<SupportTicketSummaryModel> nextTickets =
          List<SupportTicketSummaryModel>.from(tickets);
      nextTickets[index] = detail.summary;
      nextTickets.sort(
        (SupportTicketSummaryModel a, SupportTicketSummaryModel b) =>
            b.updatedAt.compareTo(a.updatedAt),
      );
      tickets = nextTickets;
    }
    ticketCount = tickets.length;
    hasChatThread = true;
    notifyListeners();
  }
}
