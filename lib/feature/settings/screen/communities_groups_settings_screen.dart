import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_loader.dart';
import '../../../route/route_names.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class CommunitiesGroupsSettingsScreen extends StatefulWidget {
  const CommunitiesGroupsSettingsScreen({super.key});

  @override
  State<CommunitiesGroupsSettingsScreen> createState() =>
      _CommunitiesGroupsSettingsScreenState();
}

class _CommunitiesGroupsSettingsScreenState
    extends State<CommunitiesGroupsSettingsScreen> {
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
      appBar: AppBar(title: const Text('Communities & Groups')),
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
                title: 'Community invites',
                subtitle: 'Allow invites to new communities',
                icon: Icons.forum_outlined,
                value: _controller.getBool(SettingsKeys.communityInvites, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.communityInvites, value),
              ),
              SettingsSwitchTile(
                title: 'Group mentions',
                subtitle: 'Notify me when mentioned in groups',
                icon: Icons.alternate_email_outlined,
                value: _controller.getBool(SettingsKeys.groupMentions, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.groupMentions, value),
              ),
              SettingsSwitchTile(
                title: 'Event reminders',
                subtitle: 'Notify me about upcoming events',
                icon: Icons.event_outlined,
                value: _controller.getBool(SettingsKeys.eventsReminders, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.eventsReminders, value),
              ),
              const SizedBox(height: 12),
              SettingsNavigationTile(
                title: 'Communities',
                subtitle: 'Browse and manage communities',
                icon: Icons.groups_outlined,
                onTap: () => Get.toNamed(RouteNames.communities),
              ),
              SettingsNavigationTile(
                title: 'Groups',
                subtitle: 'Manage group memberships',
                icon: Icons.group_work_outlined,
                onTap: () => Get.toNamed(RouteNames.groups),
              ),
              SettingsNavigationTile(
                title: 'Events',
                subtitle: 'Upcoming events and reminders',
                icon: Icons.calendar_today_outlined,
                onTap: () => Get.toNamed(RouteNames.events),
              ),
            ],
          );
        },
      ),
    );
  }
}
