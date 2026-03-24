import 'package:flutter/material.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';

class ConnectedAppsScreen extends StatefulWidget {
  const ConnectedAppsScreen({super.key});

  @override
  State<ConnectedAppsScreen> createState() => _ConnectedAppsScreenState();
}

class _ConnectedAppsScreenState extends State<ConnectedAppsScreen> {
  final SettingsStateController _controller = SettingsStateController();

  final Map<String, String> _apps = const {
    'Figma Social Kit': 'Design templates and analytics',
    'Creator Studio': 'Cross-posting and scheduling',
    'OptiZenqor Shop': 'Marketplace inventory sync',
    'Link Hub': 'Link-in-bio manager',
  };

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connected Apps')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.loaded) {
            return const Center(child: AppLoader());
          }
          final saved = _controller.getMap(SettingsKeys.connectedApps);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: _apps.entries.map((entry) {
              final isConnected = (saved[entry.key] as bool?) ?? false;
              return SwitchListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value),
                value: isConnected,
                onChanged: (value) {
                  final updated = Map<String, dynamic>.from(saved);
                  updated[entry.key] = value;
                  _controller.setMap(SettingsKeys.connectedApps, updated);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
