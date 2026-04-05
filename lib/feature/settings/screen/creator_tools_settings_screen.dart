import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/widgets/app_loader.dart';
import '../../../route/route_names.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class CreatorToolsSettingsScreen extends StatelessWidget {
  const CreatorToolsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsStateController, SettingsState>(
      builder: (context, state) {
          final controller = context.read<SettingsStateController>();
          if (!state.loaded) {
            return Scaffold(
              appBar: AppBar(title: Text('Creator Tools')),
              body: Center(child: AppLoader()),
            );
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Creator Tools')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SettingsSwitchTile(
                  title: 'Professional dashboard',
                  subtitle: 'Show creator performance insights',
                  icon: Icons.dashboard_outlined,
                  value: state.getBool(
                    SettingsKeys.professionalDashboard,
                    fallback: true,
                  ),
                  onChanged: (value) => controller.setBool(
                    SettingsKeys.professionalDashboard,
                    value,
                  ),
                ),
                SettingsSwitchTile(
                  title: 'Branded content tools',
                  subtitle: 'Label paid partnerships and collaborations',
                  icon: Icons.handshake_outlined,
                  value: state.getBool(SettingsKeys.brandedContent),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.brandedContent, value),
                ),
                SettingsSwitchTile(
                  title: 'Tips and gifts',
                  subtitle: 'Allow fans to send tips',
                  icon: Icons.volunteer_activism_outlined,
                  value: state.getBool(SettingsKeys.tips),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.tips, value),
                ),
                SettingsSwitchTile(
                  title: 'Subscriptions',
                  subtitle: 'Enable paid subscriber content',
                  icon: Icons.subscriptions_outlined,
                  value: state.getBool(SettingsKeys.subscriptions),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.subscriptions, value),
                ),
                const SizedBox(height: 12),
                SettingsNavigationTile(
                  title: 'Creator dashboard',
                  subtitle: 'View analytics and creator tools',
                  icon: Icons.insights_outlined,
                  onTap: () => AppGet.toNamed(RouteNames.creatorDashboard),
                ),
              ],
            ),
          );
      },
    );
  }
}
