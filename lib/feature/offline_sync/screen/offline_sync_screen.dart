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
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_controller.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_controller.errorMessage!),
                      ),
                    Card(
                      child: ListTile(
                        title: Text(
                          _controller.isOffline ? 'Offline mode' : 'Online',
                        ),
                        subtitle: Text(
                          _controller.queue.isEmpty
                              ? 'No queued sync actions from the backend.'
                              : 'Queued actions are being tracked by your account state.',
                        ),
                        trailing: FilledButton(
                          onPressed: _controller.markOnlineAndSync,
                          child: const Text('Sync now'),
                        ),
                      ),
                    ),
                    if (_controller.queue.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.cloud_done_outlined),
                        title: Text('Nothing is waiting to sync.'),
                      ),
                    ..._controller.queue.map(
                      (item) => ListTile(
                        title: Text(item.title),
                        trailing: Icon(
                          item.pending
                              ? Icons.sync_problem
                              : Icons.check_circle,
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
