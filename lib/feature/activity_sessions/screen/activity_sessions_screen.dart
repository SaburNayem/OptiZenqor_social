import 'package:flutter/material.dart';

import '../controller/activity_sessions_controller.dart';

class ActivitySessionsScreen extends StatelessWidget {
  ActivitySessionsScreen({super.key}) {
    controller.load();
  }

  final ActivitySessionsController controller = ActivitySessionsController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Activity & Sessions')),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: ListTile(
                        title: Text(
                          'Active sessions ${controller.activeSessions.length}',
                        ),
                        subtitle: const Text(
                          'Review your recent logins and device activity.',
                        ),
                        trailing: FilledButton(
                          onPressed: controller.loggingOutOthers
                              ? null
                              : () async {
                                  final bool hadActiveOthers = controller
                                      .sessions
                                      .any(
                                        (item) =>
                                            !item.isCurrent && item.active,
                                      );
                                  await controller.logoutOtherDevices();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            hadActiveOthers
                                                ? 'Other active sessions were refreshed from the server.'
                                                : 'No other active sessions were found.',
                                          ),
                                        ),
                                      );
                                  }
                                },
                          child: Text(
                            controller.loggingOutOthers
                                ? 'Working...'
                                : 'Logout others',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Active devices',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...controller.sessions.map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          item.isCurrent
                              ? Icons.smartphone_rounded
                              : Icons.devices_other_rounded,
                        ),
                        title: Text(item.device),
                        subtitle: Text(
                          '${item.platform} • ${item.location} • ${item.lastActive}',
                        ),
                        trailing: item.isCurrent
                            ? const Chip(label: Text('Current'))
                            : Chip(
                                label: Text(item.active ? 'Active' : 'Ended'),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Login history',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...controller.activities.map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.history_rounded),
                        title: Text(item),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
