import 'package:flutter/material.dart';

class SettingsNavigationTile extends StatelessWidget {
  const SettingsNavigationTile({
    required this.title,
    super.key,
    this.subtitle,
    this.icon,
    this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: isDestructive ? colorScheme.error : null,
      fontWeight: FontWeight.w600,
    );

    return ListTile(
      leading: icon == null ? null : Icon(icon),
      title: Text(title, style: titleStyle),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: icon == null ? null : Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      value: value,
      onChanged: onChanged,
    );
  }
}
