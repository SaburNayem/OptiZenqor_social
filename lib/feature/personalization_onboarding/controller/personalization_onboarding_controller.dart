import 'package:flutter/foundation.dart';

import '../model/interest_model.dart';

class PersonalizationOnboardingController extends ChangeNotifier {
  List<InterestModel> interests = const [
    InterestModel(name: 'Tech'),
    InterestModel(name: 'Design'),
    InterestModel(name: 'Travel'),
    InterestModel(name: 'Business'),
    InterestModel(name: 'Fitness'),
    InterestModel(name: 'Learning'),
  ];

  void toggle(String name) {
    interests = interests
        .map((item) => item.name == name
            ? InterestModel(name: item.name, selected: !item.selected)
            : item)
        .toList();
    notifyListeners();
  }
}
