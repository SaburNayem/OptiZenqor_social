import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/common_widget/app_loader.dart';
import '../../../app_route/route_names.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsStateController, SettingsState>(
      builder: (context, state) {
        final controller = context.read<SettingsStateController>();
        if (!state.loaded) {
          return Scaffold(
            appBar: AppBar(title: Text('Notifications')),
            body: Center(child: AppLoader()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Notifications')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SettingsSwitchTile(
                title: 'Push notifications',
                subtitle: 'Receive alerts on this device',
                icon: Icons.notifications_active_outlined,
                value: state.getBool(SettingsKeys.pushEnabled, fallback: true),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.pushEnabled, value),
              ),
              SettingsSwitchTile(
                title: 'Email notifications',
                subtitle: 'Important account updates by email',
                icon: Icons.email_outlined,
                value: state.getBool(SettingsKeys.emailEnabled, fallback: true),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.emailEnabled, value),
              ),
              SettingsSwitchTile(
                title: 'In-app sounds',
                subtitle: 'Play sounds for new activity',
                icon: Icons.volume_up_outlined,
                value: state.getBool(SettingsKeys.inAppSounds, fallback: true),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.inAppSounds, value),
              ),
              SettingsSwitchTile(
                title: 'Marketing updates',
                subtitle: 'Product news and promotions',
                icon: Icons.campaign_outlined,
                value: state.getBool(SettingsKeys.marketing),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.marketing, value),
              ),
              const SizedBox(height: 12),
              SettingsNavigationTile(
                title: 'Notification categories',
                subtitle: 'Fine-tune post, comment, and mention alerts',
                icon: Icons.tune_outlined,
                onTap: () =>
                    AppGet.toNamed(RouteNames.pushNotificationPreferences),
              ),
            ],
          ),
        );
      },
    );
  }
}
