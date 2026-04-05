import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';

class ConnectedAppsScreen extends StatelessWidget {
  const ConnectedAppsScreen({super.key});

  final Map<String, String> _apps = const {
    'Figma Social Kit': 'Design templates and analytics',
    'Creator Studio': 'Cross-posting and scheduling',
    'OptiZenqor Shop': 'Marketplace inventory sync',
    'Link Hub': 'Link-in-bio manager',
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsStateController>(
      create: (_) => SettingsStateController()..load(),
      child: BlocBuilder<SettingsStateController, SettingsState>(
        builder: (context, state) {
          final controller = context.read<SettingsStateController>();
          if (!state.loaded) {
            return Scaffold(
              appBar: AppBar(title: Text('Connected Apps')),
              body: Center(child: AppLoader()),
            );
          }
          final saved = state.getMap(SettingsKeys.connectedApps);
          return Scaffold(
            appBar: AppBar(title: const Text('Connected Apps')),
            body: ListView(
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
                    controller.setMap(SettingsKeys.connectedApps, updated);
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
