import 'package:flutter/foundation.dart';

import '../model/faq_item_model.dart';
import '../repository/support_help_repository.dart';

class SupportHelpController extends ChangeNotifier {
  SupportHelpController({SupportHelpRepository? repository})
      : _repository = repository ?? SupportHelpRepository();

  final SupportHelpRepository _repository;
  List<FaqItemModel> faqs = <FaqItemModel>[];

  void load() {
    faqs = _repository.loadFaqs();
    notifyListeners();
  }
}
