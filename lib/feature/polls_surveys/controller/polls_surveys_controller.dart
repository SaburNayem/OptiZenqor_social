import 'package:flutter/foundation.dart';

import '../model/poll_model.dart';
import '../repository/polls_surveys_repository.dart';

class PollsSurveysController extends ChangeNotifier {
  PollsSurveysController({PollsSurveysRepository? repository})
    : _repository = repository ?? PollsSurveysRepository();

  final PollsSurveysRepository _repository;

  List<PollModel> activeEntries = <PollModel>[];
  List<PollModel> draftEntries = <PollModel>[];
  List<String> quickTemplates = <String>[];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final payload = await _repository.load();
      activeEntries = payload.activeEntries;
      draftEntries = payload.draftEntries;
      quickTemplates = payload.quickTemplates;
    } catch (error) {
      activeEntries = const <PollModel>[];
      draftEntries = const <PollModel>[];
      quickTemplates = const <String>[];
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> vote(String id, int index) async {
    try {
      final updated = await _repository.vote(id, index);
      activeEntries = activeEntries
          .map((entry) => entry.id == id ? updated : entry)
          .toList(growable: false);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }
}
