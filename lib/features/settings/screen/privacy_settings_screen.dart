import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsStateController, SettingsState>(
      builder: (context, state) {
          final controller = context.read<SettingsStateController>();
          if (!state.loaded) {
            return Scaffold(
              appBar: AppBar(title: Text('Privacy')),
              body: Center(child: AppLoader()),
            );
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Privacy')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SettingsSwitchTile(
                  title: 'Private account',
                  subtitle: 'Only approved followers can see your posts',
                  icon: Icons.lock_outline,
                  value: state.getBool(SettingsKeys.profilePrivate),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.profilePrivate, value),
                ),
                SettingsSwitchTile(
                  title: 'Show activity status',
                  subtitle: 'Let others see when you are active',
                  icon: Icons.visibility_outlined,
                  value: state.getBool(
                    SettingsKeys.activityStatus,
                    fallback: true,
                  ),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.activityStatus, value),
                ),
                SettingsSwitchTile(
                  title: 'Allow tagging',
                  subtitle: 'Let people tag you in posts',
                  icon: Icons.tag_outlined,
                  value: state.getBool(
                    SettingsKeys.allowTagging,
                    fallback: true,
                  ),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.allowTagging, value),
                ),
                SettingsSwitchTile(
                  title: 'Allow mentions',
                  subtitle: 'Allow @mentions from followers',
                  icon: Icons.alternate_email_outlined,
                  value: state.getBool(
                    SettingsKeys.allowMentions,
                    fallback: true,
                  ),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.allowMentions, value),
                ),
                SettingsSwitchTile(
                  title: 'Allow reposts',
                  subtitle: 'Let others repost your content',
                  icon: Icons.repeat_outlined,
                  value: state.getBool(
                    SettingsKeys.allowReposts,
                    fallback: true,
                  ),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.allowReposts, value),
                ),
                SettingsSwitchTile(
                  title: 'Allow comments',
                  subtitle: 'Allow comments on your posts',
                  icon: Icons.chat_bubble_outline,
                  value: state.getBool(
                    SettingsKeys.allowComments,
                    fallback: true,
                  ),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.allowComments, value),
                ),
                SettingsSwitchTile(
                  title: 'Hide sensitive content',
                  subtitle: 'Reduce sensitive content in feed',
                  icon: Icons.shield_outlined,
                  value: state.getBool(SettingsKeys.hideSensitive),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.hideSensitive, value),
                ),
                SettingsSwitchTile(
                  title: 'Hide like counts',
                  subtitle: 'Hide likes on your posts',
                  icon: Icons.favorite_border,
                  value: state.getBool(SettingsKeys.hideLikes),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.hideLikes, value),
                ),
              ],
            ),
          );
      },
    );
  }
}
