import 'package:flutter/foundation.dart';

import '../model/poll_model.dart';
import '../repository/polls_surveys_repository.dart';

class PollsSurveysController extends ChangeNotifier {
  PollsSurveysController({PollsSurveysRepository? repository})
      : _repository = repository ?? PollsSurveysRepository();

  final PollsSurveysRepository _repository;
  PollModel? poll;

  void load() {
    poll = _repository.seed();
    notifyListeners();
  }

  void vote(int index) {
    final current = poll;
    if (current == null || index < 0 || index >= current.votes.length) {
      return;
    }
    final votes = List<int>.from(current.votes);
    votes[index] += 1;
    poll = PollModel(
      id: current.id,
      question: current.question,
      options: current.options,
      votes: votes,
    );
    notifyListeners();
  }
}
