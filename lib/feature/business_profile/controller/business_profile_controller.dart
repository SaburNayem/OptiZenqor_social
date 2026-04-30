import 'package:flutter/foundation.dart';

import '../model/business_profile_model.dart';
import '../repository/business_profile_repository.dart';

class BusinessProfileController extends ChangeNotifier {
  BusinessProfileController({BusinessProfileRepository? repository})
    : _repository = repository ?? BusinessProfileRepository();

  final BusinessProfileRepository _repository;
  BusinessProfileModel? profile;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await _repository.load();
    } catch (error) {
      profile = null;
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
