import 'package:flutter/material.dart';

import '../controller/live_stream_controller.dart';

class LiveStreamScreen extends StatelessWidget {
  LiveStreamScreen({super.key}) {
    _controller.load();
  }

  final LiveStreamController _controller = LiveStreamController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Stream')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final live = _controller.live;
          if (live == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 220,
                alignment: Alignment.center,
                color: Colors.black12,
                child: Text('Live room: ${live.roomName}'),
              ),
              const SizedBox(height: 8),
              Text('Viewers: ${live.viewerCount}'),
              ...live.comments.map(
                (comment) => ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(comment),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
