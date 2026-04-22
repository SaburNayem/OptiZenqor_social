import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/safety_privacy_model.dart';
import '../repository/safety_privacy_repository.dart';

class SafetyPrivacyController extends Cubit<SafetyPrivacyModel> {
  SafetyPrivacyController({SafetyPrivacyRepository? repository})
    : _repository = repository ?? SafetyPrivacyRepository(),
      super(const SafetyPrivacyModel());

  final SafetyPrivacyRepository _repository;

  Future<void> load() async {
    emit(await _repository.load());
  }

  Future<void> update(SafetyPrivacyModel value) async {
    await _repository.save(value);
    emit(value);
  }
}
