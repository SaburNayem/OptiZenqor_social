import 'package:flutter/material.dart';

import '../model/settings_section_model.dart';

class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({
    super.key,
    required this.section,
    required this.onItemTap,
  });

  final SettingsSectionModel section;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(section.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              section.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final item in section.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: item.icon == null ? null : Icon(item.icon),
                title: Text(
                  item.title,
                  style: item.isDestructive
                      ? theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        )
                      : null,
                ),
                subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: item.routeName == null
                    ? null
                    : () => onItemTap(item.routeName!),
              ),
          ],
        ),
      ),
    );
  }
}
