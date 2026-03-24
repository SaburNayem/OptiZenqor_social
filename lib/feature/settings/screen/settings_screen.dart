import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/theme_service.dart';
import '../../../core/widgets/section_header.dart';
import '../controller/settings_controller.dart';
import '../widget/settings_tiles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final controller = SettingsController();

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Settings')) : null,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
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
            ),
          ),
        ],
      ),
    );
  }
}
