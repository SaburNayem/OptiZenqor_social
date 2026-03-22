import 'package:flutter/foundation.dart';

import '../model/accessibility_option_model.dart';

class AccessibilitySupportController extends ChangeNotifier {
  List<AccessibilityOptionModel> options = const [
    AccessibilityOptionModel(title: 'Reduce motion', enabled: false),
    AccessibilityOptionModel(title: 'Large tap targets', enabled: true),
    AccessibilityOptionModel(title: 'High contrast labels', enabled: false),
  ];

  void toggle(int index) {
    options = options.asMap().entries.map((entry) {
      final item = entry.value;
      return entry.key == index
          ? AccessibilityOptionModel(title: item.title, enabled: !item.enabled)
          : item;
    }).toList();
    notifyListeners();
  }
}
