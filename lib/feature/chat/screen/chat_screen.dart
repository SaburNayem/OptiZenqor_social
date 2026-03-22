import 'package:flutter/material.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/helpers/format_helper.dart';
import '../../../core/widgets/error_state_view.dart';
import 'chat_detail_screen.dart';
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
        if (_controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller.hasError) {
          return ErrorStateView(
            message: _controller.state.errorMessage ?? 'Unable to load messages',
            onRetry: _controller.loadChats,
          );
        }
        if (_controller.inboxMessages.isEmpty) {
          return const Center(child: Text('No conversations yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.inboxMessages.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final message = _controller.inboxMessages[index];
            final user = MockData.users
                .where((u) => u.id == message.senderId)
                .firstOrNull;
            return ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              onTap: () {
                if (user == null) {
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ChatDetailScreen(
                      user: user,
                      initialMessage: message,
                    ),
                  ),
                );
              },
              onLongPress: () => _showChatActions(context, message.chatId),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user?.avatar ?? MockData.users.first.avatar),
              ),
              title: Text(user?.name ?? 'Unknown'),
              subtitle: Text(message.text, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_controller.isPinned(message.chatId))
                    const Icon(Icons.push_pin, size: 14),
                  Text(FormatHelper.timeAgo(message.timestamp)),
                  const SizedBox(height: 4),
                  if (_controller.unreadCount(message.chatId) > 0)
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blue,
                      child: Text(
                        _controller.unreadCount(message.chatId).toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  if (_controller.needsRetry(message.chatId))
                    TextButton(
                      onPressed: () => _controller.retry(message.chatId),
                      child: const Text('Retry'),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showChatActions(BuildContext context, String chatId) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.push_pin_outlined),
              title: Text(_controller.isPinned(chatId) ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.of(context).pop();
                _controller.togglePinned(chatId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text(_controller.isArchived(chatId) ? 'Unarchive' : 'Archive'),
              onTap: () {
                Navigator.of(context).pop();
                _controller.toggleArchived(chatId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.error_outline),
              title: const Text('Simulate send failure'),
              onTap: () {
                Navigator.of(context).pop();
                _controller.simulateSendFailure(chatId);
              },
            ),
          ],
        );
      },
    );
  }
}
