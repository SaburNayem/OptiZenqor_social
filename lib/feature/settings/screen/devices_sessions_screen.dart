import 'package:flutter/material.dart';

import '../../../route/route_names.dart';

class DevicesSessionsScreen extends StatelessWidget {
  const DevicesSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devices & Sessions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.devices_outlined),
            title: Text('Current device: Pixel Emulator'),
            subtitle: Text('Signed in now'),
          ),
          const ListTile(
            leading: Icon(Icons.history_toggle_off_rounded),
            title: Text('View activity & past sessions'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.activitySessions),
            child: const Text('Open Activity Sessions'),
          ),
        ],
      ),
    );
  }
}
