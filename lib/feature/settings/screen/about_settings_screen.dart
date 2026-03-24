import 'package:flutter/material.dart';

class AboutSettingsScreen extends StatelessWidget {
  const AboutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About OptiZenqor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('OptiZenqor Social', style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Version 0.9.0 (prototype build)', style: textTheme.bodySmall),
          const SizedBox(height: 16),
          const Text(
            'OptiZenqor Social is a creator-first social platform focused on '
            'community, commerce, and professional growth.',
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.update_outlined),
            title: Text('Release notes'),
            subtitle: Text('Preview upcoming features and fixes'),
          ),
          const ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('Open source licenses'),
            subtitle: Text('View third-party licenses'),
          ),
          const ListTile(
            leading: Icon(Icons.phone_android_outlined),
            title: Text('Device info'),
            subtitle: Text('Diagnostics and device details'),
          ),
        ],
      ),
    );
  }
}
