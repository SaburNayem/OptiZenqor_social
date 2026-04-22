import 'package:flutter/material.dart';

import '../controller/offline_sync_controller.dart';

class OfflineSyncScreen extends StatelessWidget {
  OfflineSyncScreen({super.key});

  final OfflineSyncController _controller = OfflineSyncController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Offline & Sync')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: Text(_controller.isOffline ? 'Offline mode' : 'Online'),
                  subtitle: const Text('Cached feed and draft recovery are active.'),
                  trailing: FilledButton(
                    onPressed: _controller.markOnlineAndSync,
                    child: const Text('Sync now'),
                  ),
                ),
              ),
              ..._controller.queue.map(
                (item) => ListTile(
                  title: Text(item.title),
                  trailing: Icon(
                    item.pending ? Icons.sync_problem : Icons.check_circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
