import 'package:flutter/material.dart';

import '../model/main_shell_drawer_section_model.dart';

class MainShellDrawerSection extends StatelessWidget {
  const MainShellDrawerSection({
    super.key,
    required this.section,
    required this.onTap,
  });

  final MainShellDrawerSectionModel section;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(section.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  section.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ...section.items.map(
            (item) => ListTile(
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: Icon(item.icon),
              title: Text(item.title),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => onTap(item.routeName),
            ),
          ),
        ],
      ),
    );
  }
}
