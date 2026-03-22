import 'package:flutter/foundation.dart';

import '../model/privacy_setting_model.dart';

class AdvancedPrivacyControlsController extends ChangeNotifier {
  List<PrivacySettingModel> settings = const [
    PrivacySettingModel(title: 'Private account', value: false),
    PrivacySettingModel(title: 'Allow mentions', value: true),
    PrivacySettingModel(title: 'Allow comments from everyone', value: true),
    PrivacySettingModel(title: 'Close friends stories only', value: false),
    PrivacySettingModel(title: 'Hidden words filter', value: true),
  ];

  void toggle(int index) {
    settings = settings.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      if (i != index) {
        return item;
      }
      return PrivacySettingModel(title: item.title, value: !item.value);
    }).toList();
    notifyListeners();
  }
}
