import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/common_widget/app_loader.dart';
import '../../../app_route/route_names.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class MessagesCallsSettingsScreen extends StatelessWidget {
  const MessagesCallsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsStateController, SettingsState>(
      builder: (context, state) {
        final controller = context.read<SettingsStateController>();
        if (!state.loaded) {
          return Scaffold(
            appBar: AppBar(title: Text('Messages & Calls')),
            body: Center(child: AppLoader()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Messages & Calls')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SettingsSwitchTile(
                title: 'Message requests',
                subtitle: 'Allow message requests from new people',
                icon: Icons.mark_unread_chat_alt_outlined,
                value: state.getBool(
                  SettingsKeys.messageRequests,
                  fallback: true,
                ),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.messageRequests, value),
              ),
              SettingsSwitchTile(
                title: 'Read receipts',
                subtitle: 'Let others see when you read messages',
                icon: Icons.done_all_outlined,
                value: state.getBool(SettingsKeys.readReceipts, fallback: true),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.readReceipts, value),
              ),
              SettingsSwitchTile(
                title: 'Allow calls',
                subtitle: 'Enable voice and video calls',
                icon: Icons.call_outlined,
                value: state.getBool(SettingsKeys.allowCalls, fallback: true),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.allowCalls, value),
              ),
              SettingsSwitchTile(
                title: 'Auto-download media',
                subtitle: 'Download media on Wi-Fi',
                icon: Icons.cloud_download_outlined,
                value: state.getBool(
                  SettingsKeys.autoDownloadMedia,
                  fallback: true,
                ),
                onChanged: (value) =>
                    controller.setBool(SettingsKeys.autoDownloadMedia, value),
              ),
              const SizedBox(height: 12),
              SettingsNavigationTile(
                title: 'Call preferences',
                subtitle: 'Manage call history and devices',
                icon: Icons.settings_phone_outlined,
                onTap: () => AppGet.toNamed(RouteNames.calls),
              ),
            ],
          ),
        );
      },
    );
  }
}
