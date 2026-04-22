import 'package:flutter/material.dart';

import '../controller/report_center_controller.dart';

class ReportCenterScreen extends StatelessWidget {
  ReportCenterScreen({super.key});

  final ReportCenterController _controller = ReportCenterController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Report Center')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Report reason'),
              Wrap(
                spacing: 8,
                children: _controller.reasons
                    .map(
                      (reason) => ActionChip(
                        label: Text(reason),
                        onPressed: () => _controller.submit(reason),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text('Report history'),
              ..._controller.history.map(
                (item) => ListTile(
                  title: Text(item.reason),
                  subtitle: Text(item.status),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
