import 'package:flutter/material.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class FeedContentPreferencesScreen extends StatefulWidget {
  const FeedContentPreferencesScreen({super.key});

  @override
  State<FeedContentPreferencesScreen> createState() =>
      _FeedContentPreferencesScreenState();
}

class _FeedContentPreferencesScreenState
    extends State<FeedContentPreferencesScreen> {
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
      appBar: AppBar(title: const Text('Feed & Content Preferences')),
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
                title: 'Autoplay videos',
                subtitle: 'Play reels and videos automatically',
                icon: Icons.play_circle_outline,
                value: _controller.getBool(SettingsKeys.autoplay, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.autoplay, value),
              ),
              SettingsSwitchTile(
                title: 'Data saver',
                subtitle: 'Reduce data usage on cellular',
                icon: Icons.data_saver_on_outlined,
                value: _controller.getBool(SettingsKeys.dataSaver),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.dataSaver, value),
              ),
              SettingsSwitchTile(
                title: 'Hide topics',
                subtitle: 'Mute specific topics from feed',
                icon: Icons.visibility_off_outlined,
                value: _controller.getBool(SettingsKeys.hideTopics),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.hideTopics, value),
              ),
              SettingsSwitchTile(
                title: 'Reset recommendations',
                subtitle: 'Reset your feed recommendations',
                icon: Icons.restart_alt_outlined,
                value: _controller.getBool(SettingsKeys.resetRecommendations),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.resetRecommendations, value),
              ),
            ],
          );
        },
      ),
    );
  }
}
