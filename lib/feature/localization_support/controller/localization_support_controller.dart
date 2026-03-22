import 'package:flutter/foundation.dart';

import '../model/localization_option_model.dart';

class LocalizationSupportController extends ChangeNotifier {
  final List<LocalizationOptionModel> locales = const [
    LocalizationOptionModel(localeCode: 'en', label: 'English'),
    LocalizationOptionModel(localeCode: 'es', label: 'Spanish'),
    LocalizationOptionModel(localeCode: 'ar', label: 'Arabic (RTL ready)'),
  ];

  String selected = 'en';

  void setLocale(String code) {
    selected = code;
    notifyListeners();
  }
}
