import 'package:flutter/foundation.dart';

import '../model/faq_item_model.dart';
import '../model/support_help_data_model.dart';
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
  bool isLoading = false;
  String? errorMessage;

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
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      faqs = <FaqItemModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
