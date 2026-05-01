import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/common_widget/app_loader.dart';
import '../../../app_route/route_names.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class CommunitiesGroupsSettingsScreen extends StatelessWidget {
  const CommunitiesGroupsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsStateController, SettingsState>(
      builder: (context, state) {
        final controller = context.read<SettingsStateController>();
        if (!state.loaded) {
          return Scaffold(
            appBar: AppBar(title: Text('Communities & Groups')),
            body: Center(child: AppLoader()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Communities & Groups')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SettingsSwitchTile(
                title: 'Community invites',
                subtitle: 'Allow invites to new communities',
                icon: Icons.forum_outlined,
                value: state.getBool(
                  SettingsKeys.communityInvites,
                  fallback: true,
                ),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.communityInvites, value),
              ),
              SettingsSwitchTile(
                title: 'Group mentions',
                subtitle: 'Notify me when mentioned in groups',
                icon: Icons.alternate_email_outlined,
                value: state.getBool(
                  SettingsKeys.groupMentions,
                  fallback: true,
                ),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.groupMentions, value),
              ),
              SettingsSwitchTile(
                title: 'Event reminders',
                subtitle: 'Notify me about upcoming events',
                icon: Icons.event_outlined,
                value: state.getBool(
                  SettingsKeys.eventsReminders,
                  fallback: true,
                ),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.eventsReminders, value),
              ),
              const SizedBox(height: 12),
              SettingsNavigationTile(
                title: 'Communities',
                subtitle: 'Browse and manage communities',
                icon: Icons.groups_outlined,
                onTap: () => AppGet.toNamed(RouteNames.communities),
              ),
              SettingsNavigationTile(
                title: 'Groups',
                subtitle: 'Manage group memberships',
                icon: Icons.group_work_outlined,
                onTap: () => AppGet.toNamed(RouteNames.groups),
              ),
              SettingsNavigationTile(
                title: 'Events',
                subtitle: 'Upcoming events and reminders',
                icon: Icons.calendar_today_outlined,
                onTap: () => AppGet.toNamed(RouteNames.events),
              ),
            ],
          ),
        );
      },
    );
  }
}
