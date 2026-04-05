import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/widgets/app_loader.dart';
import '../../../route/route_names.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  final SettingsStateController _controller = SettingsStateController();

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
      appBar: AppBar(title: const Text('Notifications')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.loaded) {
            return const Center(child: AppLoader());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SettingsSwitchTile(
                title: 'Push notifications',
                subtitle: 'Receive alerts on this device',
                icon: Icons.notifications_active_outlined,
                value: _controller.getBool(SettingsKeys.pushEnabled, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.pushEnabled, value),
              ),
              SettingsSwitchTile(
                title: 'Email notifications',
                subtitle: 'Important account updates by email',
                icon: Icons.email_outlined,
                value: _controller.getBool(SettingsKeys.emailEnabled, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.emailEnabled, value),
              ),
              SettingsSwitchTile(
                title: 'In-app sounds',
                subtitle: 'Play sounds for new activity',
                icon: Icons.volume_up_outlined,
                value: _controller.getBool(SettingsKeys.inAppSounds, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.inAppSounds, value),
              ),
              SettingsSwitchTile(
                title: 'Marketing updates',
                subtitle: 'Product news and promotions',
                icon: Icons.campaign_outlined,
                value: _controller.getBool(SettingsKeys.marketing),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.marketing, value),
              ),
              const SizedBox(height: 12),
              SettingsNavigationTile(
                title: 'Notification categories',
                subtitle: 'Fine-tune post, comment, and mention alerts',
                icon: Icons.tune_outlined,
                onTap: () => AppGet.toNamed(RouteNames.pushNotificationPreferences),
              ),
            ],
          );
        },
      ),
    );
  }
}
