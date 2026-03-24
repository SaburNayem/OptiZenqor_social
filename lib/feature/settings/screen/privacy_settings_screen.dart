import 'package:flutter/material.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
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
      appBar: AppBar(title: const Text('Privacy')),
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
                title: 'Private account',
                subtitle: 'Only approved followers can see your posts',
                icon: Icons.lock_outline,
                value: _controller.getBool(SettingsKeys.profilePrivate),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.profilePrivate, value),
              ),
              SettingsSwitchTile(
                title: 'Show activity status',
                subtitle: 'Let others see when you are active',
                icon: Icons.visibility_outlined,
                value: _controller.getBool(SettingsKeys.activityStatus, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.activityStatus, value),
              ),
              SettingsSwitchTile(
                title: 'Allow tagging',
                subtitle: 'Let people tag you in posts',
                icon: Icons.tag_outlined,
                value: _controller.getBool(SettingsKeys.allowTagging, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.allowTagging, value),
              ),
              SettingsSwitchTile(
                title: 'Allow mentions',
                subtitle: 'Allow @mentions from followers',
                icon: Icons.alternate_email_outlined,
                value: _controller.getBool(SettingsKeys.allowMentions, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.allowMentions, value),
              ),
              SettingsSwitchTile(
                title: 'Allow reposts',
                subtitle: 'Let others repost your content',
                icon: Icons.repeat_outlined,
                value: _controller.getBool(SettingsKeys.allowReposts, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.allowReposts, value),
              ),
              SettingsSwitchTile(
                title: 'Allow comments',
                subtitle: 'Allow comments on your posts',
                icon: Icons.chat_bubble_outline,
                value: _controller.getBool(SettingsKeys.allowComments, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.allowComments, value),
              ),
              SettingsSwitchTile(
                title: 'Hide sensitive content',
                subtitle: 'Reduce sensitive content in feed',
                icon: Icons.shield_outlined,
                value: _controller.getBool(SettingsKeys.hideSensitive),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.hideSensitive, value),
              ),
              SettingsSwitchTile(
                title: 'Hide like counts',
                subtitle: 'Hide likes on your posts',
                icon: Icons.favorite_border,
                value: _controller.getBool(SettingsKeys.hideLikes),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.hideLikes, value),
              ),
            ],
          );
        },
      ),
    );
  }
}
