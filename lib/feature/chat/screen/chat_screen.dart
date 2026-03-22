import 'package:flutter/material.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/helpers/format_helper.dart';
import '../controller/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController _controller = ChatController();

  @override
  void initState() {
    super.initState();
    _controller.loadChats();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.messages.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final message = _controller.messages[index];
            final user = MockData.users
                .where((u) => u.id == message.senderId)
                .firstOrNull;
            return ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user?.avatar ?? MockData.users.first.avatar),
              ),
              title: Text(user?.name ?? 'Unknown'),
              subtitle: Text(message.text, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(FormatHelper.timeAgo(message.timestamp)),
                  const SizedBox(height: 4),
                  if (!message.read)
                    const CircleAvatar(radius: 4, backgroundColor: Colors.blue),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
