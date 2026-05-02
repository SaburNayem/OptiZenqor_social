import 'package:flutter/material.dart';

import '../controller/share_repost_system_controller.dart';

class ShareRepostSystemScreen extends StatelessWidget {
  ShareRepostSystemScreen({super.key});

  final ShareRepostSystemController _controller = ShareRepostSystemController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Share & Repost')),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    if (_controller.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_controller.errorMessage!),
                      ),
                    if (_controller.options.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.share_outlined),
                        title: Text(
                          'No share options are available right now.',
                        ),
                      ),
                    ..._controller.options.map(
                      (option) => ListTile(
                        title: Text(option),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
