import 'package:flutter/foundation.dart';

import '../model/push_category_model.dart';

class PushNotificationPreferencesController extends ChangeNotifier {
  List<PushCategoryModel> categories = const [
    PushCategoryModel(title: 'Likes', enabled: true),
    PushCategoryModel(title: 'Comments', enabled: true),
    PushCategoryModel(title: 'Messages', enabled: true),
    PushCategoryModel(title: 'Live alerts', enabled: false),
  ];

  void toggle(int index) {
    categories = categories.asMap().entries.map((entry) {
      final item = entry.value;
      return entry.key == index
          ? PushCategoryModel(title: item.title, enabled: !item.enabled)
          : item;
    }).toList();
    notifyListeners();
  }
}
