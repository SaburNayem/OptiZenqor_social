import 'package:flutter/foundation.dart';

import '../model/safety_privacy_model.dart';
import '../repository/safety_privacy_repository.dart';

class SafetyPrivacyController extends ChangeNotifier {
  SafetyPrivacyController({SafetyPrivacyRepository? repository})
      : _repository = repository ?? SafetyPrivacyRepository();

  final SafetyPrivacyRepository _repository;
  SafetyPrivacyModel settings = const SafetyPrivacyModel();

  Future<void> load() async {
    settings = await _repository.load();
    notifyListeners();
  }

  Future<void> update(SafetyPrivacyModel value) async {
    settings = value;
    await _repository.save(value);
    notifyListeners();
  }
}
