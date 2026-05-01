import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/common_widget/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class FeedContentPreferencesScreen extends StatelessWidget {
  const FeedContentPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsStateController, SettingsState>(
      builder: (context, state) {
        final controller = context.read<SettingsStateController>();
        if (!state.loaded) {
          return Scaffold(
            appBar: AppBar(title: Text('Feed & Content Preferences')),
            body: Center(child: AppLoader()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Feed & Content Preferences')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SettingsSwitchTile(
                title: 'Autoplay videos',
                subtitle: 'Play reels and videos automatically',
                icon: Icons.play_circle_outline,
                value: state.getBool(SettingsKeys.autoplay, fallback: true),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.autoplay, value),
              ),
              SettingsSwitchTile(
                title: 'Data saver',
                subtitle: 'Reduce data usage on cellular',
                icon: Icons.data_saver_on_outlined,
                value: state.getBool(SettingsKeys.dataSaver),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.dataSaver, value),
              ),
              SettingsSwitchTile(
                title: 'Hide topics',
                subtitle: 'Mute specific topics from feed',
                icon: Icons.visibility_off_outlined,
                value: state.getBool(SettingsKeys.hideTopics),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.hideTopics, value),
              ),
              SettingsSwitchTile(
                title: 'Reset recommendations',
                subtitle: 'Reset your feed recommendations',
                icon: Icons.restart_alt_outlined,
                value: state.getBool(SettingsKeys.resetRecommendations),
                onChanged: (value) => controller.setBool(
                  SettingsKeys.resetRecommendations,
                  value,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
