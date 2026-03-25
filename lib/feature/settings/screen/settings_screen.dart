import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/service/theme_service.dart';
import '../common/settings_section_card.dart';
import '../controller/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController(), permanent: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Settings')) : null,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Control Center', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  controller.roleLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeService.instance.mode,
                  builder: (_, mode, _) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.palette_outlined),
                      title: const Text('Theme mode'),
                      subtitle: Text('Current mode: ${mode.name}'),
                      trailing: DropdownButton<ThemeMode>(
                        value: mode,
                        onChanged: (value) {
                          if (value != null) {
                            ThemeService.instance.setTheme(value);
                          }
                        },
                        items: ThemeMode.values
                            .map(
                              (item) => DropdownMenuItem<ThemeMode>(
                                value: item,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ...controller.sections.map(
            (section) => SettingsSectionCard(
              section: section,
              onItemTap: Get.toNamed,
            ),
          ),
        ],
      ),
    );
  }
}
