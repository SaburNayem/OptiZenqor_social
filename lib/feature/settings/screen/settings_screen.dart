import 'package:flutter/material.dart';

import '../controller/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final controller = SettingsController();

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Settings')) : null,
      body: ListView(
        children: [
          ...controller.items.map(
            (item) => _Item(title: item.title, routeName: item.routeName),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.title, this.routeName});

  final String title;
  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: routeName == null
          ? null
          : () => Navigator.of(context).pushNamed(routeName!),
    );
  }
}
