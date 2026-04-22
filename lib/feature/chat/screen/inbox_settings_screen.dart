import 'package:flutter/material.dart';

import '../controller/inbox_settings_controller.dart';
import '../../../core/constants/app_colors.dart';

class InboxSettingsScreen extends StatelessWidget {
  InboxSettingsScreen({super.key})
    : _controller = InboxSettingsController();

  final InboxSettingsController _controller;

  static const List<String> _privacyOptions = <String>[
    'Everyone',
    'Friends / Followers only',
    'No one',
  ];

  static const List<String> _visibilityOptions = <String>[
    'Everyone',
    'Contacts',
    'Nobody',
  ];

  static const List<String> _toneOptions = <String>[
    'Default',
    'Ripple',
    'Glass',
    'Pulse',
  ];

  static const List<String> _channelOptions = <String>[
    'Push + In-app',
    'Push only',
    'In-app only',
    'Email only',
  ];

  static const List<String> _mediaOptions = <String>[
    'Off',
    'WiFi',
    'Mobile',
  ];

  static const List<String> _exportFormats = <String>[
    'PDF',
    'JSON',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Inbox Settings')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _buildSectionTitle('Message Requests & Privacy'),
              _buildDropdownTile(
                label: 'Who can message me',
                value: _controller.whoCanMessageMe,
                options: _privacyOptions,
                onChanged: _controller.setWhoCanMessageMe,
              ),
              SwitchListTile(
                value: _controller.messageRequestsFolder,
                onChanged: _controller.setMessageRequestsFolder,
                title: const Text('Message requests folder'),
                subtitle: const Text('Send unknown users to requests'),
              ),
              SwitchListTile(
                value: _controller.autoFilterSpam,
                onChanged: _controller.setAutoFilterSpam,
                title: const Text('Auto-filter spam messages'),
              ),
              SwitchListTile(
                value: _controller.allowBusinessMessages,
                onChanged: _controller.setAllowBusinessMessages,
                title: const Text('Allow business/promotional messages'),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Notifications'),
              SwitchListTile(
                value: _controller.newMessageNotifications,
                onChanged: _controller.setNewMessageNotifications,
                title: const Text('New message notifications'),
              ),
              SwitchListTile(
                value: _controller.messageRequestNotifications,
                onChanged: _controller.setMessageRequestNotifications,
                title: const Text('Message request notifications'),
              ),
              SwitchListTile(
                value: _controller.groupMessageNotifications,
                onChanged: _controller.setGroupMessageNotifications,
                title: const Text('Group message notifications'),
              ),
              SwitchListTile(
                value: _controller.silentMode,
                onChanged: _controller.setSilentMode,
                title: const Text('Silent mode'),
                subtitle: const Text('Mute all chats globally'),
              ),
              _buildDropdownTile(
                label: 'Custom notification tone',
                value: _controller.notificationTone,
                options: _toneOptions,
                onChanged: _controller.setNotificationTone,
              ),
              _buildDropdownTile(
                label: 'Push vs in-app vs email',
                value: _controller.notificationChannel,
                options: _channelOptions,
                onChanged: _controller.setNotificationChannel,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Read Receipts'),
              SwitchListTile(
                value: _controller.sendReadReceipts,
                onChanged: _controller.setSendReadReceipts,
                title: const Text('Send read receipts'),
              ),
              SwitchListTile(
                value: _controller.showSeenStatus,
                onChanged: _controller.setShowSeenStatus,
                title: const Text('Show seen status'),
              ),
              _buildDropdownTile(
                label: 'Last seen visibility',
                value: _controller.lastSeenVisibility,
                options: _visibilityOptions,
                onChanged: _controller.setLastSeenVisibility,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Active Status / Online Presence'),
              SwitchListTile(
                value: _controller.showOnlineStatus,
                onChanged: _controller.setShowOnlineStatus,
                title: const Text('Show online status'),
              ),
              SwitchListTile(
                value: _controller.showTypingIndicator,
                onChanged: _controller.setShowTypingIndicator,
                title: const Text('Show typing indicator'),
              ),
              SwitchListTile(
                value: _controller.showLastActiveTime,
                onChanged: _controller.setShowLastActiveTime,
                title: const Text('Show last active time'),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Chat Backup & Sync'),
              SwitchListTile(
                value: _controller.cloudBackup,
                onChanged: _controller.setCloudBackup,
                title: const Text('Cloud backup'),
                subtitle: const Text('Firebase / Supabase ready flow'),
              ),
              SwitchListTile(
                value: _controller.autoSyncDevices,
                onChanged: _controller.setAutoSyncDevices,
                title: const Text('Auto-sync messages across devices'),
              ),
              _buildActionTile(context, 'Restore chats', Icons.restore_rounded),
              _buildDropdownTile(
                label: 'Export chats format',
                value: _controller.exportFormat,
                options: _exportFormats,
                onChanged: _controller.setExportFormat,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Media Auto-Download'),
              _buildDropdownTile(
                label: 'Auto-download images',
                value: _controller.imageAutoDownload,
                options: _mediaOptions,
                onChanged: _controller.setImageAutoDownload,
              ),
              _buildDropdownTile(
                label: 'Auto-download videos',
                value: _controller.videoAutoDownload,
                options: _mediaOptions,
                onChanged: _controller.setVideoAutoDownload,
              ),
              _buildDropdownTile(
                label: 'Auto-download audio / voice notes',
                value: _controller.audioAutoDownload,
                options: _mediaOptions,
                onChanged: _controller.setAudioAutoDownload,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Storage usage control'),
                subtitle: Text('${_controller.storageLimitMb.round()} MB'),
              ),
              Slider(
                value: _controller.storageLimitMb,
                min: 128,
                max: 2048,
                divisions: 15,
                label: '${_controller.storageLimitMb.round()} MB',
                onChanged: _controller.setStorageLimitMb,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Safety & Control'),
              _buildActionTile(context, 'Blocked users list', Icons.block_outlined),
              _buildActionTile(context, 'Muted users list', Icons.volume_off_outlined),
              _buildActionTile(context, 'Report center', Icons.report_outlined),
              _buildActionTile(context, 'Restricted users', Icons.visibility_off_outlined),
              _buildActionTile(context, 'Keyword filtering', Icons.filter_alt_outlined),
              const SizedBox(height: 16),
              _buildSectionTitle('Chat Appearance'),
              _buildActionTile(context, 'Default chat theme', Icons.palette_outlined),
              _buildActionTile(context, 'Font size', Icons.format_size_outlined),
              _buildActionTile(context, 'Chat bubble style', Icons.chat_bubble_outline),
              _buildActionTile(context, 'Dark / light mode', Icons.dark_mode_outlined),
              const SizedBox(height: 16),
              _buildSectionTitle('Advanced Features'),
              SwitchListTile(
                value: _controller.aiAutoReply,
                onChanged: _controller.setAiAutoReply,
                title: const Text('AI auto-reply'),
              ),
              SwitchListTile(
                value: _controller.smartSuggestions,
                onChanged: _controller.setSmartSuggestions,
                title: const Text('Smart suggestions'),
              ),
              SwitchListTile(
                value: _controller.autoTranslate,
                onChanged: _controller.setAutoTranslate,
                title: const Text('Translate messages automatically'),
              ),
              SwitchListTile(
                value: _controller.multiDeviceSessions,
                onChanged: _controller.setMultiDeviceSessions,
                title: const Text('Multi-device session management'),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Developer Features'),
              _buildInfoCard(<String>[
                'Message status tracking: sending -> sent -> delivered -> read',
                'Typing indicator debounce',
                'Offline queue with retry',
                'Sync unread count with backend',
                'Pagination for older messages',
                'Read timestamp and seen-by support',
              ]),
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

  Widget _buildActionTile(BuildContext context, String label, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showInfo(context, '$label opened'),
    );
  }

  Widget _buildInfoCard(List<String> items) {
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



