import 'package:flutter/material.dart';

import '../controller/jobs_networking_controller.dart';

class JobsNetworkingScreen extends StatelessWidget {
  JobsNetworkingScreen({super.key}) {
    _controller.load();
  }

  final JobsNetworkingController _controller = JobsNetworkingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jobs Networking')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            ..._controller.jobs.map(
              (job) => Card(
                child: ListTile(
                  title: Text(job.title),
                  subtitle: Text(job.company),
                  onTap: () => _controller.select(job),
                ),
              ),
            ),
            if (_controller.selected != null) ...<Widget>[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: Text(_controller.selected!.title),
                  subtitle: Text(
                    '${_controller.selected!.company}\n${_controller.selected!.description}',
                  ),
                  isThreeLine: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
