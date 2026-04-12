import 'package:flutter/material.dart';

import '../controller/push_notification_preferences_controller.dart';

class PushNotificationPreferencesScreen extends StatelessWidget {
  PushNotificationPreferencesScreen({super.key});

  final PushNotificationPreferencesController _controller =
      PushNotificationPreferencesController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Push Preferences')),
          body: ListView.builder(
            itemCount: _controller.categories.length,
            itemBuilder: (context, index) {
              final item = _controller.categories[index];
              return SwitchListTile(
                title: Text(item.title),
                value: item.enabled,
                onChanged: (_) => _controller.toggle(index),
              );
            },
          ),
        );
      },
    );
  }
}
