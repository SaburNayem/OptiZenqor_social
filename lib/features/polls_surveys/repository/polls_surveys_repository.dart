import '../model/poll_model.dart';

class PollsSurveysRepository {
  PollModel seed() => const PollModel(id: 'poll_1', question: 'Which feature should ship next?', options: <String>['Group calls', 'Collections', 'Jobs'], votes: <int>[10, 6, 8]);
}
