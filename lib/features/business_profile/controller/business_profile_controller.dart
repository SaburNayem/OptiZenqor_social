import 'package:flutter/foundation.dart';

import '../model/business_profile_model.dart';
import '../repository/business_profile_repository.dart';

class BusinessProfileController extends ChangeNotifier {
  BusinessProfileController({BusinessProfileRepository? repository})
      : _repository = repository ?? BusinessProfileRepository();

  final BusinessProfileRepository _repository;
  BusinessProfileModel? profile;

  void load() {
    profile = _repository.load();
    notifyListeners();
  }
}
