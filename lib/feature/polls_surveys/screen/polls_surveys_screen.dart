import 'package:flutter/material.dart';

import '../controller/polls_surveys_controller.dart';

class PollsSurveysScreen extends StatelessWidget {
  PollsSurveysScreen({super.key}) {
    _controller.load();
  }

  final PollsSurveysController _controller = PollsSurveysController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Polls & Surveys')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final poll = _controller.poll;
          if (poll == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final total = poll.votes.fold<int>(0, (sum, vote) => sum + vote);
          final safeTotal = total == 0 ? 1 : total;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                poll.question,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...List.generate(poll.options.length, (index) {
                final percentage = (poll.votes[index] / safeTotal) * 100;
                return Card(
                  child: ListTile(
                    title: Text(poll.options[index]),
                    subtitle: Text(
                      '${poll.votes[index]} votes • '
                      '${percentage.toStringAsFixed(1)}%',
                    ),
                    trailing: FilledButton(
                      onPressed: () => _controller.vote(index),
                      child: const Text('Vote'),
                    ),
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
