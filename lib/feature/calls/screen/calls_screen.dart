import 'package:flutter/material.dart';

import '../controller/calls_controller.dart';
import '../model/call_item_model.dart';
import 'audio_call_screen.dart';
import 'video_call_screen.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  final CallsController _controller = CallsController();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_controller.load);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calls')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          if (_controller.isLoading && _controller.callHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await _controller.startCall(
                          user: 'mayaquinn',
                          type: CallType.voice,
                        );
                        if (!context.mounted) {
                          return;
                        }
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
                      onPressed: () async {
                        await _controller.startCall(
                          user: 'mayaquinn',
                          type: CallType.video,
                        );
                        if (!context.mounted) {
                          return;
                        }
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
              if (_controller.errorMessage != null &&
                  _controller.errorMessage!.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _controller.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              if (_controller.callHistory.isEmpty)
                const Card(
                  child: ListTile(
                    title: Text('No calls yet'),
                    subtitle: Text(
                      'Your backend call history will appear here.',
                    ),
                  ),
                ),
              ..._controller.callHistory.map(
                (call) => Card(
                  child: ListTile(
                    leading: Icon(
                      call.type == CallType.video ? Icons.videocam : Icons.call,
                    ),
                    title: Text('@${call.user}'),
                    subtitle: Text(
                      '${call.state.name} - ${call.time.hour}:${call.time.minute.toString().padLeft(2, '0')}',
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
