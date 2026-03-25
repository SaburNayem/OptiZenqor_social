import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/theme_service.dart';
<<<<<<< HEAD
import '../../../core/widgets/section_header.dart';
=======
import '../common/settings_section_card.dart';
>>>>>>> 08433d8 (update)
import '../controller/settings_controller.dart';
import '../widget/settings_tiles.dart';

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
        children: [
<<<<<<< HEAD
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SectionHeader(title: 'Appearance'),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeService.instance.mode,
              builder: (_, mode, _) {
                return ListTile(
                  title: const Text('Theme mode'),
                  subtitle: Text(mode.name),
                  trailing: DropdownButton<ThemeMode>(
                    value: mode,
                    onChanged: (value) {
                      if (value != null) {
                        ThemeService.instance.setTheme(value);
                      }
                    },
                    items: ThemeMode.values
                        .map((item) => DropdownMenuItem<ThemeMode>(
                              value: item,
                              child: Text(item.name),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          ...controller.sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: SectionHeader(title: section.title),
                  ),
                  if (section.description != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        section.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: section.items
                          .map(
                            (item) => SettingsNavigationTile(
                              title: item.title,
                              subtitle: item.subtitle,
                              icon: item.icon,
                              isDestructive: item.isDestructive,
                              onTap: item.routeName == null
                                  ? null
                                  : () => Get.toNamed(item.routeName!),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
=======
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
>>>>>>> 08433d8 (update)
            ),
          ),
        ],
      ),
    );
  }
}
