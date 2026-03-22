import 'package:flutter/material.dart';

import '../controller/maintenance_mode_controller.dart';

class MaintenanceModeScreen extends StatelessWidget {
  const MaintenanceModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MaintenanceModeController();

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
              Text(controller.state.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(controller.state.message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: () {}, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}
