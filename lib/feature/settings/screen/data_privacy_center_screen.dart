import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class DataPrivacyCenterScreen extends StatelessWidget {
  const DataPrivacyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsStateController>(
      create: (_) => SettingsStateController()..load(),
      child: BlocBuilder<SettingsStateController, SettingsState>(
        builder: (context, state) {
          final controller = context.read<SettingsStateController>();
          if (!state.loaded) {
            return Scaffold(
              appBar: AppBar(title: Text('Data & Privacy Center')),
              body: Center(child: AppLoader()),
            );
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Data & Privacy Center')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SettingsSwitchTile(
                  title: 'Ad personalization',
                  subtitle: 'Use activity to personalize ads',
                  icon: Icons.campaign_outlined,
                  value: state.getBool(
                    SettingsKeys.adPersonalization,
                    fallback: true,
                  ),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.adPersonalization, value),
                ),
                SettingsSwitchTile(
                  title: 'Data collection',
                  subtitle: 'Allow analytics to improve recommendations',
                  icon: Icons.analytics_outlined,
                  value: state.getBool(
                    SettingsKeys.dataCollection,
                    fallback: true,
                  ),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.dataCollection, value),
                ),
                SettingsSwitchTile(
                  title: 'Export my data',
                  subtitle: 'Request a downloadable copy of your data',
                  icon: Icons.download_outlined,
                  value: state.getBool(SettingsKeys.dataExport),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.dataExport, value),
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
            ),
          );
        },
      ),
    );
  }
}
