import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/common_widget/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  final List<String> _textSizes = const [
    'Small',
    'Default',
    'Large',
    'Extra Large',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsStateController, SettingsState>(
      builder: (context, state) {
          final controller = context.read<SettingsStateController>();
          if (!state.loaded) {
            return Scaffold(
              appBar: AppBar(title: Text('Accessibility')),
              body: Center(child: AppLoader()),
            );
          }
          final textSize = state.getString(
            SettingsKeys.textSize,
            fallback: _textSizes[1],
          );
          return Scaffold(
            appBar: AppBar(title: const Text('Accessibility')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SettingsSwitchTile(
                  title: 'Captions',
                  subtitle: 'Show captions on supported media',
                  icon: Icons.closed_caption_outlined,
                  value: state.getBool(SettingsKeys.captions),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.captions, value),
                ),
                SettingsSwitchTile(
                  title: 'High contrast',
                  subtitle: 'Increase contrast for readability',
                  icon: Icons.brightness_6_outlined,
                  value: state.getBool(SettingsKeys.highContrast),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.highContrast, value),
                ),
                SettingsSwitchTile(
                  title: 'Reduce motion',
                  subtitle: 'Limit animations and motion effects',
                  icon: Icons.motion_photos_off_outlined,
                  value: state.getBool(SettingsKeys.reduceMotion),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.reduceMotion, value),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.text_fields_outlined),
                  title: const Text('Text size'),
                  subtitle: Text(textSize),
                  trailing: DropdownButton<String>(
                    value: textSize,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setString(SettingsKeys.textSize, value);
                      }
                    },
                    items: _textSizes
                        .map(
                          (size) => DropdownMenuItem<String>(
                            value: size,
                            child: Text(size),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
      },
    );
  }
}

