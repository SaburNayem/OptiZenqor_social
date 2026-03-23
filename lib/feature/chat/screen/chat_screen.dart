import 'package:flutter/material.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/helpers/format_helper.dart';
import '../../../core/widgets/error_state_view.dart';
import 'chat_detail_screen.dart';
import '../controller/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key}) {
    _controller.loadChats();
  }

  final ChatController _controller = ChatController();

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
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.sticky_note_2_outlined),
                title: const Text('Today\'s note'),
                subtitle: const Text('Shipping creator messaging polish'),
                trailing: const Chip(label: Text('Followers')),
              ),
            ),
            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.mail_outline),
                    title: Text('Message requests inbox'),
                    subtitle: Text('Accept/decline request flow'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.report_gmailerrorred_outlined),
                    title: Text('Spam request placeholder'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ..._controller.inboxMessages.map((message) {
              final user = MockData.users
                  .where((u) => u.id == message.senderId)
                  .firstOrNull;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
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
                ),
              );
            }),
          ],
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
            ListTile(
              leading: const Icon(Icons.mark_chat_unread_outlined),
              title: const Text('Mark chat unread'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat marked unread placeholder')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
