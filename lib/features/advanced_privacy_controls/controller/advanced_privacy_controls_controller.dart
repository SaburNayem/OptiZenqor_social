import 'package:flutter/foundation.dart';

import '../model/privacy_setting_model.dart';

class AdvancedPrivacyControlsController extends ChangeNotifier {
  List<PrivacySettingModel> settings = const [
    PrivacySettingModel(title: 'Private account', value: false),
    PrivacySettingModel(title: 'Allow mentions', value: true),
    PrivacySettingModel(title: 'Allow comments from everyone', value: true),
    PrivacySettingModel(title: 'Close friends stories only', value: false),
    PrivacySettingModel(title: 'Hidden words filter', value: true),
    PrivacySettingModel(title: 'Restrict interaction settings', value: false),
    PrivacySettingModel(title: 'Sensitive content filter', value: true),
    PrivacySettingModel(title: 'Anti-spam placeholder', value: true),
    PrivacySettingModel(title: 'Child/teen safety placeholder', value: true),
    PrivacySettingModel(title: 'Parental control placeholder', value: false),
    PrivacySettingModel(title: 'Data saver media mode', value: false),
    PrivacySettingModel(title: 'Auto-play control settings', value: true),
    PrivacySettingModel(title: 'Reduced motion toggle', value: false),
    PrivacySettingModel(title: 'High contrast mode placeholder', value: false),
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
