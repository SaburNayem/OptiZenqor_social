import 'package:flutter/material.dart';

import '../../../core/common_models/message_model.dart';
import '../../../core/common_models/user_model.dart';
import '../../../core/helpers/format_helper.dart';
import 'chat_settings_screen.dart';

class ChatDetailScreen extends StatelessWidget {
  ChatDetailScreen({
    required this.user,
    required this.initialMessage,
    super.key,
  }) : _messages = ValueNotifier<List<MessageModel>>(
          <MessageModel>[
            MessageModel(
              id: 'local-1',
              chatId: initialMessage.chatId,
              senderId: user.id,
              text: initialMessage.text,
              timestamp: initialMessage.timestamp,
              read: true,
            ),
            MessageModel(
              id: 'local-2',
              chatId: initialMessage.chatId,
              senderId: 'me',
              text: 'Looks good. Let us ship this by tonight.',
              timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
              read: true,
            ),
            MessageModel(
              id: 'local-3',
              chatId: initialMessage.chatId,
              senderId: user.id,
              text: 'Perfect. Sending final assets now.',
              timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
              read: false,
            ),
          ],
        );

  final UserModel user;
  final MessageModel initialMessage;

  final ValueNotifier<List<MessageModel>> _messages;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<int?> _unreadMarkerIndex = ValueNotifier<int?>(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontSize: 16)),
                  const Text('typing...', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Audio call',
            onPressed: () => _startCall(context, isVideo: false),
            icon: const Icon(Icons.call_outlined),
          ),
          IconButton(
            tooltip: 'Video call',
            onPressed: () => _startCall(context, isVideo: true),
            icon: const Icon(Icons.videocam_outlined),
          ),
          IconButton(
            tooltip: 'Chat settings',
            onPressed: () => _openChatSettings(context),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search in conversation',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Chip(label: Text('Media')),
                SizedBox(width: 8),
                Chip(label: Text('Docs')),
                SizedBox(width: 8),
                Chip(label: Text('Links')),
                SizedBox(width: 8),
                Chip(label: Text('Reply threading')),
                SizedBox(width: 8),
                Chip(label: Text('Disappearing messages')),
                SizedBox(width: 8),
                Chip(label: Text('Theme/wallpaper')),
                SizedBox(width: 8),
                Chip(label: Text('Encrypted chat')),
                SizedBox(width: 8),
                Chip(label: Text('E2E placeholder')),
                SizedBox(width: 8),
                Chip(label: Text('Screenshot warning')),
                SizedBox(width: 8),
                Chip(label: Text('Media auto-expire')),
                SizedBox(width: 8),
                Chip(label: Text('Device-based chat session')),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<MessageModel>>(
              valueListenable: _messages,
              builder: (context, messages, _) {
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMe = message.senderId == 'me';
                    return Column(
                      children: [
                        if (_unreadMarkerIndex.value == index)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Chip(label: Text('Unread marker jump')),
                          ),
                        Align(
                          alignment:
                              isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(message.text),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  FormatHelper.timeAgo(message.timestamp),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  children: const [
                                    Chip(label: Text('Star')),
                                    Chip(label: Text('Reply')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _openAttachmentMenu(context),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  IconButton(
                    onPressed: () => _showFeedback(
                      context,
                      'Voice note recording placeholder',
                    ),
                    icon: const Icon(Icons.mic_none_rounded),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(context),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _sendMessage(context),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAttachmentMenu(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () => _handleAttachmentAction(context, 'Gallery selected'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () => _handleAttachmentAction(context, 'Camera opened'),
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: const Text('Document'),
                onTap: () => _handleAttachmentAction(context, 'Document picker opened'),
              ),
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Location'),
                onTap: () => _handleAttachmentAction(context, 'Live location shared'),
              ),
              ListTile(
                leading: const Icon(Icons.access_time_outlined),
                title: const Text('Disappearing message timer'),
                onTap: () => _handleAttachmentAction(
                  context,
                  'Disappearing messages placeholder',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAttachmentAction(BuildContext context, String message) {
    Navigator.of(context).pop();
    _showFeedback(context, message);
  }

  void _sendMessage(BuildContext context) {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    _messages.value = <MessageModel>[
      ..._messages.value,
      MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: initialMessage.chatId,
        senderId: 'me',
        text: text,
        timestamp: DateTime.now(),
        read: true,
      ),
    ];
    _messageController.clear();
  }

  void _startCall(BuildContext context, {required bool isVideo}) {
    final mode = isVideo ? 'Video call' : 'Audio call';
    _showFeedback(context, '$mode started with ${user.name}');
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openChatSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatSettingsScreen(
          chatId: initialMessage.chatId,
          title: user.name,
        ),
      ),
    );
  }
}
