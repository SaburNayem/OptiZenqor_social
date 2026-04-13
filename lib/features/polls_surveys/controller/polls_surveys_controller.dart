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

  void load() {
    activeEntries = _repository.activeEntries();
    draftEntries = _repository.draftEntries();
    quickTemplates = _repository.quickTemplates();
    notifyListeners();
  }

  void vote(String id, int index) {
    activeEntries = activeEntries.map((entry) {
      if (entry.id != id || index < 0 || index >= entry.votes.length) {
        return entry;
      }

      final updatedVotes = List<int>.from(entry.votes);
      updatedVotes[index] += 1;
      return entry.copyWith(
        votes: updatedVotes,
        responseCount: entry.responseCount + 1,
      );
    }).toList();

    notifyListeners();
  }
}
