import 'package:flutter/material.dart';

import '../controller/maintenance_mode_controller.dart';

class MaintenanceModeScreen extends StatelessWidget {
  MaintenanceModeScreen({super.key});

  final MaintenanceModeController _controller = MaintenanceModeController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Maintenance Mode')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.construction_rounded, size: 56),
                  const SizedBox(height: 14),
                  Text(
                    _controller.state.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(_controller.state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _controller.isRetrying
                        ? null
                        : () async {
                            await _controller.retry();
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(content: Text('Service is available now.')),
                              );
                          },
                    child: Text(_controller.isRetrying ? 'Retrying...' : 'Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
