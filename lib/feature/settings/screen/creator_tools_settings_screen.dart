import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_loader.dart';
import '../../../route/route_names.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class CreatorToolsSettingsScreen extends StatefulWidget {
  const CreatorToolsSettingsScreen({super.key});

  @override
  State<CreatorToolsSettingsScreen> createState() =>
      _CreatorToolsSettingsScreenState();
}

class _CreatorToolsSettingsScreenState
    extends State<CreatorToolsSettingsScreen> {
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
      appBar: AppBar(title: const Text('Creator Tools')),
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
                title: 'Professional dashboard',
                subtitle: 'Show creator performance insights',
                icon: Icons.dashboard_outlined,
                value: _controller.getBool(SettingsKeys.professionalDashboard, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.professionalDashboard, value),
              ),
              SettingsSwitchTile(
                title: 'Branded content tools',
                subtitle: 'Label paid partnerships and collaborations',
                icon: Icons.handshake_outlined,
                value: _controller.getBool(SettingsKeys.brandedContent),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.brandedContent, value),
              ),
              SettingsSwitchTile(
                title: 'Tips and gifts',
                subtitle: 'Allow fans to send tips',
                icon: Icons.volunteer_activism_outlined,
                value: _controller.getBool(SettingsKeys.tips),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.tips, value),
              ),
              SettingsSwitchTile(
                title: 'Subscriptions',
                subtitle: 'Enable paid subscriber content',
                icon: Icons.subscriptions_outlined,
                value: _controller.getBool(SettingsKeys.subscriptions),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.subscriptions, value),
              ),
              const SizedBox(height: 12),
              SettingsNavigationTile(
                title: 'Creator dashboard',
                subtitle: 'View analytics and creator tools',
                icon: Icons.insights_outlined,
                onTap: () => Get.toNamed(RouteNames.creatorDashboard),
              ),
            ],
          );
        },
      ),
    );
  }
}
