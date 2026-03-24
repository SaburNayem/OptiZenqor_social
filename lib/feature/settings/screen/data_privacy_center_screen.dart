import 'package:flutter/material.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class DataPrivacyCenterScreen extends StatefulWidget {
  const DataPrivacyCenterScreen({super.key});

  @override
  State<DataPrivacyCenterScreen> createState() => _DataPrivacyCenterScreenState();
}

class _DataPrivacyCenterScreenState extends State<DataPrivacyCenterScreen> {
  final SettingsStateController _controller = SettingsStateController();

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
      appBar: AppBar(title: const Text('Data & Privacy Center')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.loaded) {
            return const Center(child: AppLoader());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SettingsSwitchTile(
                title: 'Ad personalization',
                subtitle: 'Use activity to personalize ads',
                icon: Icons.campaign_outlined,
                value: _controller.getBool(SettingsKeys.adPersonalization, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.adPersonalization, value),
              ),
              SettingsSwitchTile(
                title: 'Data collection',
                subtitle: 'Allow analytics to improve recommendations',
                icon: Icons.analytics_outlined,
                value: _controller.getBool(SettingsKeys.dataCollection, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.dataCollection, value),
              ),
              SettingsSwitchTile(
                title: 'Export my data',
                subtitle: 'Request a downloadable copy of your data',
                icon: Icons.download_outlined,
                value: _controller.getBool(SettingsKeys.dataExport),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.dataExport, value),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Cache cleared locally')),
                    );
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear cached data'),
              ),
            ],
          );
        },
      ),
    );
  }
}
