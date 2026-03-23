import 'package:flutter/foundation.dart';

import '../model/poll_model.dart';
import '../repository/polls_surveys_repository.dart';

class PollsSurveysController extenclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSullclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSullclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSurveysController extenclam(class PollsSurveysController extenclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSullclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSurveysController extenclass PollsSurveysController extenclaser/polls_surveys_controller.dart';

class PollsSurveysScreen extends StatelessWidget {
  PollsSurveysScreen({super.key}) { _controller.load(); }
  final PollsSurveysController _controller = PollsSurveysController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Polls & Surveys')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final poll = _controller.poll;
          if (poll == null) return const Center(child: CircularProgressIndicator());
          final total = poll.votes.fold<int>(0, (a, b) => a + b).clamp(1, 999999);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(poll.question, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...List.generate(poll.options.length, (index) {
                final p = (poll.votes[index] / total) * 100;
                return Card(
                  child: ListTile(
                    title: Text(poll.options[index]),
                    subtitle: Text('${poll.votes[index]} votes • ${p.toStringAsFixed(1)}%'),
                    trailing: FilledButton(onPressed: () => _controller.vote(index), child: const Text('Vote')),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
