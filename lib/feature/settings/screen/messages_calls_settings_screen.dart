import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_loader.dart';
import '../../../route/route_names.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class MessagesCallsSettingsScreen extends StatefulWidget {
  const MessagesCallsSettingsScreen({super.key});

  @override
  State<MessagesCallsSettingsScreen> createState() =>
      _MessagesCallsSettingsScreenState();
}

class _MessagesCallsSettingsScreenState
    extends State<MessagesCallsSettingsScreen> {
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
      appBar: AppBar(title: const Text('Messages & Calls')),
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
                title: 'Message requests',
                subtitle: 'Allow message requests from new people',
                icon: Icons.mark_unread_chat_alt_outlined,
                value: _controller.getBool(SettingsKeys.messageRequests, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.messageRequests, value),
              ),
              SettingsSwitchTile(
                title: 'Read receipts',
                subtitle: 'Let others see when you read messages',
                icon: Icons.done_all_outlined,
                value: _controller.getBool(SettingsKeys.readReceipts, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.readReceipts, value),
              ),
              SettingsSwitchTile(
                title: 'Allow calls',
                subtitle: 'Enable voice and video calls',
                icon: Icons.call_outlined,
                value: _controller.getBool(SettingsKeys.allowCalls, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.allowCalls, value),
              ),
              SettingsSwitchTile(
                title: 'Auto-download media',
                subtitle: 'Download media on Wi-Fi',
                icon: Icons.cloud_download_outlined,
                value: _controller.getBool(SettingsKeys.autoDownloadMedia, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.autoDownloadMedia, value),
              ),
              const SizedBox(height: 12),
              SettingsNavigationTile(
                title: 'Call preferences',
                subtitle: 'Manage call history and devices',
                icon: Icons.settings_phone_outlined,
                onTap: () => Get.toNamed(RouteNames.calls),
              ),
            ],
          );
        },
      ),
    );
  }
}
