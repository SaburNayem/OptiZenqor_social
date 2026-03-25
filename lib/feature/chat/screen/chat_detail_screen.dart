import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/common_models/message_model.dart';
import '../../../core/common_models/user_model.dart';

class ChatDetailScreen extends StatelessWidget {
  ChatDetailScreen({
    required this.user,
    required this.initialMessage,
    super.key,
  }) : _messages = ValueNotifier<List<MessageModel>>(
          <MessageModel>[
            MessageModel(
              id: 'm1',
              chatId: initialMessage.chatId,
              senderId: user.id,
              text: 'Hey Alex! How are you doing?',
              timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
              read: true,
            ),
            MessageModel(
              id: 'm2',
              chatId: initialMessage.chatId,
              senderId: 'me',
              text: 'Hey Sarah! I am doing great, just working on a new project. How about you?',
              timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
              read: true,
            ),
            MessageModel(
              id: 'm3',
              chatId: initialMessage.chatId,
              senderId: user.id,
              text: 'Same here. Been super busy this week.',
              timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
              read: true,
            ),
            MessageModel(
              id: 'm4',
              chatId: initialMessage.chatId,
              senderId: user.id,
              text: 'Are we still on for tomorrow?',
              timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
              read: true,
            ),
          ],
        );

  final UserModel user;
  final MessageModel initialMessage;

  final ValueNotifier<List<MessageModel>> _messages;
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(user.avatar),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00ACC1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.grey),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 0.5),
          Expanded(
            child: ValueListenableBuilder<List<MessageModel>>(
              valueListenable: _messages,
              builder: (context, messages, _) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length + 1, // +1 for the "Today" label
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }

                    final message = messages[index - 1];
                    final isMe = message.senderId == 'me';
                    final showAvatar = !isMe &&
                        (index == 1 || messages[index - 2].senderId == 'me');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe)
                                SizedBox(
                                  width: 40,
                                  child: showAvatar
                                      ? CircleAvatar(
                                          radius: 16,
                                          backgroundImage: NetworkImage(user.avatar),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              if (!isMe) const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isMe ? const Color(0xFF26C6DA) : Colors.grey.shade50,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                                      bottomRight: Radius.circular(isMe ? 4 : 20),
                                    ),
                                    border: isMe ? null : Border.all(color: Colors.grey.shade100),
                                  ),
                                  child: Text(
                                    message.text,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsets.only(
                              left: isMe ? 0 : 48,
                              right: isMe ? 4 : 0,
                            ),
                            child: Text(
                              DateFormat('h:mm a').format(message.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(context),
        ],
      ),
    );
  }

  Widget _buildMessageComposer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.attach_file, color: Colors.grey),
          ),
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.sentiment_satisfied_alt_outlined, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.image_outlined, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
