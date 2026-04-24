import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/common_widget/error_state_view.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/enums/user_role.dart';
import '../../home_feed/controller/main_shell_controller.dart';
import '../controller/chat_controller.dart';
import 'chat_detail_screen.dart';
import 'inbox_settings_screen.dart';
import 'chat_settings_screen.dart';
import '../../../core/constants/app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChatController()..loadChats();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel currentUser = context.read<MainShellController>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Chats'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => InboxSettingsScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(currentUser.avatar),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.hasError) {
            return ErrorStateView(
              message:
                  _controller.state.errorMessage ?? 'Unable to load messages',
              onRetry: _controller.loadChats,
            );
          }

          final inbox = _controller.inboxMessages;
          final List<UserModel> conversationUsers = inbox
              .map((message) => _userFor(message.senderId))
              .toList(growable: false);
          if (inbox.isEmpty) {
            return const Center(child: Text('No chats available'));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      AppGet.snackbar('Search', 'Static message search opened');
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: AppColors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Search messages...',
                            style: TextStyle(
                              color: AppColors.grey400,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Online Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.hexFF263238,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: conversationUsers.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 20),
                        itemBuilder: (context, index) {
                          final user = conversationUsers[index];
                          return InkWell(
                            onTap: () {
                              AppGet.snackbar(
                                'Quick Chat',
                                'Started static chat with ${user.name}',
                              );
                            },
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage(
                                        user.avatar,
                                      ),
                                    ),
                                    Positioned(
                                      right: 2,
                                      bottom: 2,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: AppColors.hexFF4CAF50,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user.name.split(' ').first,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.hexFF263238,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final message = inbox[index];
                  final user = _userFor(message.senderId);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Dismissible(
                      key: ValueKey(message.chatId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.red400,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, color: AppColors.white),
                            SizedBox(height: 4),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      confirmDismiss: (_) =>
                          _confirmChatDelete(context, user.name),
                      onDismissed: (_) {
                        _controller.deleteConversation(message.chatId);
                        AppGet.snackbar(
                          'Chat Deleted',
                          'Conversation with ${user.name} removed',
                        );
                      },
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ChatDetailScreen(
                                user: user,
                                initialMessage: message,
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showChatOptions(message.chatId, user.name);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.hexFFF0F0F0),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: NetworkImage(user.avatar),
                                  ),
                                  Positioned(
                                    right: 2,
                                    bottom: 2,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: AppColors.hexFF4CAF50,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _timeLabel(message.timestamp),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                _controller.unreadCount(
                                                      message.chatId,
                                                    ) >
                                                    0
                                                ? AppColors.hexFF00ACC1
                                                : AppColors.grey,
                                            fontWeight:
                                                _controller.unreadCount(
                                                      message.chatId,
                                                    ) >
                                                    0
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            message.text,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  _controller.unreadCount(
                                                        message.chatId,
                                                      ) >
                                                      0
                                                  ? AppColors.black87
                                                  : AppColors.grey,
                                              fontWeight:
                                                  _controller.unreadCount(
                                                        message.chatId,
                                                      ) >
                                                      0
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (_controller.unreadCount(
                                              message.chatId,
                                            ) >
                                            0)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: AppColors.hexFF00ACC1,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${_controller.unreadCount(message.chatId)}',
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'pin') {
                                    _controller.togglePinned(message.chatId);
                                  } else if (value == 'archive') {
                                    _controller.toggleArchived(message.chatId);
                                  } else if (value == 'mute') {
                                    AppGet.snackbar(
                                      'Mute',
                                      '${user.name} conversation muted',
                                    );
                                  } else if (value == 'settings') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ChatSettingsScreen(
                                          chatId: message.chatId,
                                          title: user.name,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'pin',
                                    child: Text('Pin'),
                                  ),
                                  PopupMenuItem(
                                    value: 'settings',
                                    child: Text('Chat settings'),
                                  ),
                                  PopupMenuItem(
                                    value: 'archive',
                                    child: Text('Archive'),
                                  ),
                                  PopupMenuItem(
                                    value: 'mute',
                                    child: Text('Mute'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: inbox.length),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChatOptions(String chatId, String name) {
    AppGet.bottomSheet(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.push_pin_outlined),
              title: const Text('Pin chat'),
              onTap: () {
                AppGet.back();
                _controller.togglePinned(chatId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive chat'),
              onTap: () {
                AppGet.back();
                _controller.toggleArchived(chatId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_off_outlined),
              title: const Text('Mute conversation'),
              onTap: () {
                AppGet.back();
                AppGet.snackbar('Mute', '$name conversation muted');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Chat settings'),
              onTap: () {
                AppGet.back();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ChatSettingsScreen(chatId: chatId, title: name),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  Future<bool?> _confirmChatDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete chat?'),
          content: Text(
            'Are you sure you want to delete the conversation with $name?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _timeLabel(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }
    return '${difference.inDays}d';
  }

  UserModel _userFor(String userId) {
    final String cleanId = userId.trim();
    final String username = cleanId.isEmpty ? 'user' : cleanId;
    final String displayName = username
        .replaceAll(RegExp(r'[_\\-]+'), ' ')
        .trim();
    return UserModel(
      id: cleanId,
      name: displayName.isEmpty ? 'Conversation' : displayName,
      username: username,
      avatar: 'https://placehold.co/120x120',
      bio: '',
      role: UserRole.user,
      followers: 0,
      following: 0,
    );
  }
}




