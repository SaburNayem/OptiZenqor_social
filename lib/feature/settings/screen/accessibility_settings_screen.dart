import 'package:flutter/material.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen> {
  final SettingsStateController _controller = SettingsStateController();

  final List<String> _textSizes = const ['Small', 'Default', 'Large', 'Extra Large'];

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
      appBar: AppBar(title: const Text('Accessibility')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.loaded) {
            return const Center(child: AppLoader());
          }
          final textSize = _controller.getString(
            SettingsKeys.textSize,
            fallback: _textSizes[1],
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SettingsSwitchTile(
                title: 'Captions',
                subtitle: 'Show captions on supported media',
                icon: Icons.closed_caption_outlined,
                value: _controller.getBool(SettingsKeys.captions),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.captions, value),
              ),
              SettingsSwitchTile(
                title: 'High contrast',
                subtitle: 'Increase contrast for readability',
                icon: Icons.brightness_6_outlined,
                value: _controller.getBool(SettingsKeys.highContrast),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.highContrast, value),
              ),
              SettingsSwitchTile(
                title: 'Reduce motion',
                subtitle: 'Limit animations and motion effects',
                icon: Icons.motion_photos_off_outlined,
                value: _controller.getBool(SettingsKeys.reduceMotion),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.reduceMotion, value),
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
                      _controller.setString(SettingsKeys.textSize, value);
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
          );
        },
      ),
    );
  }
}
