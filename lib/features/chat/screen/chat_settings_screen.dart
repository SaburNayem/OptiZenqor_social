import 'package:flutter/material.dart';

import '../controller/chat_settings_controller.dart';
import '../../../core/constants/app_colors.dart';

class ChatSettingsScreen extends StatelessWidget {
  ChatSettingsScreen({
    required this.chatId,
    required this.title,
    this.isGroupChat = false,
    super.key,
  }) : _controller = ChatSettingsController(chatId: chatId);

  final String chatId;
  final String title;
  final bool isGroupChat;
  final ChatSettingsController _controller;

  static const List<String> _muteOptions = <String>[
    'Off',
    '1 hour',
    '8 hours',
    '24 hours',
    'Forever',
  ];

  static const List<String> _toneOptions = <String>[
    'Default',
    'Ripple',
    'Glass',
    'Pulse',
  ];

  static const List<String> _themeOptions = <String>[
    'Ocean',
    'Sunset',
    'Forest',
    'Midnight',
  ];

  static const List<String> _wallpaperOptions = <String>[
    'Default',
    'Blur',
    'Gradient',
    'Photo',
  ];

  static const List<String> _selfDestructOptions = <String>[
    'Off',
    '5 sec',
    '10 sec',
    '1 min',
    '1 day',
  ];

  static const List<String> _permissionOptions = <String>[
    'Everyone',
    'Admins only',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text('$title Chat Settings')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _buildSectionTitle('Chat Info'),
              _buildNavTile(context, 'View profile', Icons.person_outline),
              _buildNavTile(context, 'Shared media/files', Icons.perm_media_outlined),
              _buildNavTile(context, 'Links & documents', Icons.link_outlined),
              _buildNavTile(context, 'Search in chat', Icons.search_rounded),
              const SizedBox(height: 16),
              _buildSectionTitle('Notifications'),
              _buildDropdownTile(
                label: 'Mute chat',
                value: _controller.muteDuration,
                options: _muteOptions,
                onChanged: _controller.setMuteDuration,
              ),
              _buildDropdownTile(
                label: 'Custom notification tone',
                value: _controller.notificationTone,
                options: _toneOptions,
                onChanged: _controller.setNotificationTone,
              ),
              SwitchListTile(
                value: _controller.priorityNotifications,
                onChanged: _controller.setPriorityNotifications,
                title: const Text('Priority notifications'),
                subtitle: const Text('Pin important chat alerts to the top'),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Privacy Controls'),
              SwitchListTile(
                value: _controller.blockUser,
                onChanged: _controller.setBlockUser,
                title: const Text('Block user'),
              ),
              SwitchListTile(
                value: _controller.restrictUser,
                onChanged: _controller.setRestrictUser,
                title: const Text('Restrict user'),
              ),
              SwitchListTile(
                value: _controller.disappearingMessages,
                onChanged: _controller.setDisappearingMessages,
                title: const Text('Disappear messages'),
                subtitle: const Text('Enable vanish mode for this conversation'),
              ),
              _buildActionTile(
                context,
                'Report conversation',
                Icons.report_outlined,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Message Controls'),
              _buildActionTile(context, 'Delete chat', Icons.delete_outline, destructive: true),
              _buildActionTile(context, 'Clear chat', Icons.clear_all_rounded),
              _buildActionTile(context, 'Archive chat', Icons.archive_outlined),
              _buildActionTile(context, 'Pin chat', Icons.push_pin_outlined),
              _buildActionTile(context, 'Mark as unread', Icons.mark_chat_unread_outlined),
              const SizedBox(height: 16),
              _buildSectionTitle('Media & Storage'),
              SwitchListTile(
                value: _controller.saveMediaToGallery,
                onChanged: _controller.setSaveMediaToGallery,
                title: const Text('Save media to gallery'),
              ),
              SwitchListTile(
                value: _controller.autoDownloadMedia,
                onChanged: _controller.setAutoDownloadMedia,
                title: const Text('Auto-download media'),
                subtitle: const Text('Override global inbox media settings'),
              ),
              _buildActionTile(context, 'Storage usage for this chat', Icons.storage_rounded),
              const SizedBox(height: 16),
              _buildSectionTitle('Customization'),
              _buildDropdownTile(
                label: 'Custom chat theme',
                value: _controller.customTheme,
                options: _themeOptions,
                onChanged: _controller.setCustomTheme,
              ),
              _buildActionTile(context, 'Custom emoji / reaction set', Icons.emoji_emotions_outlined),
              _buildTextTile(
                context: context,
                label: 'Nickname for user',
                value: _controller.nickname,
                hint: 'Set nickname',
                onSaved: _controller.setNickname,
              ),
              _buildDropdownTile(
                label: 'Custom wallpaper',
                value: _controller.wallpaper,
                options: _wallpaperOptions,
                onChanged: _controller.setWallpaper,
              ),
              if (isGroupChat) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('Group Chat'),
                _buildActionTile(context, 'Group info', Icons.groups_outlined),
                _buildActionTile(context, 'Add/remove members', Icons.group_add_outlined),
                _buildDropdownTile(
                  label: 'Who can send messages',
                  value: _controller.messagePermission,
                  options: _permissionOptions,
                  onChanged: _controller.setMessagePermission,
                ),
                _buildDropdownTile(
                  label: 'Who can add members',
                  value: _controller.memberAddPermission,
                  options: _permissionOptions,
                  onChanged: _controller.setMemberAddPermission,
                ),
                SwitchListTile(
                  value: _controller.groupMentionsEnabled,
                  onChanged: _controller.setGroupMentionsEnabled,
                  title: const Text('Mentions control (@everyone)'),
                ),
                _buildActionTile(context, 'Exit group / delete group', Icons.logout_rounded, destructive: true),
              ],
              const SizedBox(height: 16),
              _buildSectionTitle('Advanced Features'),
              SwitchListTile(
                value: _controller.encryptionEnabled,
                onChanged: _controller.setEncryptionEnabled,
                title: const Text('End-to-end encryption'),
              ),
              _buildDropdownTile(
                label: 'Self-destruct timer',
                value: _controller.selfDestructTimer,
                options: _selfDestructOptions,
                onChanged: _controller.setSelfDestructTimer,
              ),
              SwitchListTile(
                value: _controller.voiceVideoCallsAllowed,
                onChanged: _controller.setVoiceVideoCallsAllowed,
                title: const Text('Voice / video call permissions'),
              ),
              SwitchListTile(
                value: _controller.reactionsEnabled,
                onChanged: _controller.setReactionsEnabled,
                title: const Text('Message reactions control'),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Developer Features'),
              _buildInfoCard(
                context,
                <String>[
                  'Message status tracking: sending -> sent -> delivered -> read',
                  'Typing indicator debounce',
                  'Offline queue and retry',
                  'Sync unread count with backend',
                  'Pagination and lazy loading',
                  'Seen by and read timestamp support',
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNavTile(BuildContext context, String label, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showInfo(context, '$label coming next'),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String label,
    IconData icon, {
    bool destructive = false,
  }) {
    final Color? color = destructive ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: () => _showInfo(context, '$label updated'),
    );
  }

  Widget _buildDropdownTile({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: (next) {
          if (next != null) {
            onChanged(next);
          }
        },
        items: options
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTextTile({
    required BuildContext context,
    required String label,
    required String value,
    required String hint,
    required ValueChanged<String> onSaved,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value.isEmpty ? hint : value),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () async {
        final TextEditingController controller = TextEditingController(text: value);
        final String? result = await showDialog<String>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(label),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: hint),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
        if (result != null) {
          onSaved(result);
        }
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(item),
                ))
            .toList(),
      ),
    );
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}



