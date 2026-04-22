import 'package:flutter/material.dart';

import '../controller/calls_controller.dart';
import '../model/call_item_model.dart';
import 'audio_call_screen.dart';
import 'video_call_screen.dart';

class CallsScreen extends StatelessWidget {
  CallsScreen({super.key}) {
    _controller.load();
  }

  final CallsController _controller = CallsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calls')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _controller.startCall(
                          user: 'mayaquinn',
                          type: CallType.voice,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AudioCallScreen(
                              name: 'Maya Quinn',
                              avatarUrl:
                                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.call_outlined),
                      label: const Text('Voice Call UI'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _controller.startCall(
                          user: 'mayaquinn',
                          type: CallType.video,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const VideoCallScreen(
                              name: 'Maya Quinn',
                              avatarUrl:
                                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.videocam_outlined),
                      label: const Text('Video Call UI'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._controller.callHistory.map(
                (call) => Card(
                  child: ListTile(
                    leading: Icon(
                      call.type == CallType.video ? Icons.videocam : Icons.call,
                    ),
                    title: Text('@${call.user}'),
                    subtitle: Text(
                      '${call.state.name} • ${call.time.hour}:${call.time.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
