import 'package:flutter/material.dart';

import '../../../app_route/route_names.dart';
import '../../activity_sessions/controller/activity_sessions_controller.dart';

class DevicesSessionsScreen extends StatelessWidget {
  DevicesSessionsScreen({super.key}) {
    _controller.load();
  }

  final ActivitySessionsController _controller = ActivitySessionsController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final currentSessions = _controller.sessions
            .where((item) => item.isCurrent)
            .toList();
        final currentSession = currentSessions.isEmpty
            ? null
            : currentSessions.first;
        return Scaffold(
          appBar: AppBar(title: const Text('Devices & Sessions')),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.devices_outlined),
                      title: Text(
                        'Current device: ${currentSession?.device ?? 'Unknown'}',
                      ),
                      subtitle: Text(
                        currentSession == null
                            ? 'No current session information'
                            : '${currentSession.platform} • ${currentSession.location} • ${currentSession.lastActive}',
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.history_toggle_off_rounded),
                      title: Text(
                        'Login history: ${_controller.activities.length} events',
                      ),
                      subtitle: Text(
                        'Active sessions: ${_controller.activeSessions.length}',
                      ),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(RouteNames.activitySessions),
                      child: const Text('Open Activity Sessions'),
                    ),
                    const SizedBox(height: 12),
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text(
                          'Session security is backed by your account',
                        ),
                        subtitle: Text(
                          'Use Activity Sessions to review current devices, login history, and remote sign-outs.',
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
