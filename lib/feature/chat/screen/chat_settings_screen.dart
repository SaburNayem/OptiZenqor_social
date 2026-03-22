import 'package:flutter/material.dart';

import '../controller/chat_settings_controller.dart';

class ChatSettingsScreen extends StatelessWidget {
  ChatSettingsScreen({
    required this.chatId,
    required this.title,
    super.key,
  }) : _controller = ChatSettingsController(chatId: chatId);

  final String chatId;
  final String title;
  final ChatSettingsController _controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text('$title Settings')),
          body: ListView(
            children: [
              const SizedBox(height: 8),
              SwitchListTile(
                value: _controller.muteNotifications,
                onChanged: _controller.toggleMute,
                title: const Text('Mute notifications'),
                subtitle: const Text('Silence alerts for this chat'),
              ),
              SwitchListTile(
                value: _controller.pinnedConversation,
                onChanged: _controller.togglePinned,
                title: const Text('Pin conversation'),
                subtitle: const Text('Keep this chat at the top of inbox'),
              ),
              SwitchListTile(
                value: _controller.readReceipts,
                onChanged: _controller.toggleReadReceipts,
                title: const Text('Read receipts'),
                subtitle: const Text('Let others see when you have read messages'),
              ),
              SwitchListTile(
                value: _controller.mediaAutoDownload,
                onChanged: _controller.toggleMediaAutoDownload,
                title: const Text('Auto-download media'),
                subtitle: const Text('Automatically save incoming photos/videos'),
              ),
              SwitchListTile(
                value: _controller.disappearingMessages,
                onChanged: _controller.toggleDisappearingMessages,
                title: const Text('Disappearing messages'),
                subtitle: const Text('Messages disappear after 24 hours'),
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('Shared media'),
                subtitle: const Text('View photos, videos, and files in this chat'),
                onTap: () => _showInfo(context, 'Shared media screen coming next'),
              ),
              ListTile(
                leading: const Icon(Icons.search_rounded),
                title: const Text('Search in conversation'),
                subtitle: const Text('Find messages by keyword'),
                onTap: () => _showInfo(context, 'Conversation search is not available yet'),
              ),
              ListTile(
                leading: Icon(
                  Icons.clear_all_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Clear chat history',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => _showInfo(context, 'Chat history cleared for this device'),
              ),
              ListTile(
                leading: Icon(
                  Icons.block_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Block user',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => _showInfo(context, 'User blocked successfully'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
