import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/common_widget/error_state_view.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/message_model.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../home_feed/controller/main_shell_controller.dart';
import '../../home_feed/repository/home_feed_repository.dart';
import '../../stories/widget/story_ring_list.dart';
import '../controller/chat_controller.dart';
import '../model/chat_thread_model.dart';
import '../repository/chat_repository.dart';
import 'chat_detail_screen.dart';
import 'chat_settings_screen.dart';
import 'inbox_settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _controller;
  final HomeFeedRepository _homeFeedRepository = HomeFeedRepository();
  final ChatRepository _chatRepository = ChatRepository();
  List<StoryModel> _stories = <StoryModel>[];
  bool _isLoadingStories = false;
  bool _isOpeningStoryReply = false;

  @override
  void initState() {
    super.initState();
    _controller = ChatController()..loadChats();
    _loadStories();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadStories() async {
    setState(() => _isLoadingStories = true);
    final List<StoryModel> stories = await _homeFeedRepository.fetchStories(
      scope: 'buddies',
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _stories = stories;
      _isLoadingStories = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserModel currentUser = context
        .read<MainShellController>()
        .currentUser;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Chats'),
        actions: <Widget>[
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

          final List<ChatThreadModel> inbox = _controller.inboxThreads;
          final List<UserModel> conversationUsers = inbox
              .map((ChatThreadModel thread) => thread.user)
              .where((UserModel user) => user.id.isNotEmpty)
              .toList(growable: false);
          final List<UserModel> storyUsers = _storyUsers(
            currentUser: currentUser,
            conversationUsers: conversationUsers,
          );
          if (inbox.isEmpty && _stories.isEmpty && !_isLoadingStories) {
            return const Center(child: Text('No chats available'));
          }

          return CustomScrollView(
            slivers: <Widget>[
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
                        children: <Widget>[
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
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Stories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.hexFF263238,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingStories)
                      const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_stories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'No buddy stories right now',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      )
                    else
                      StoryRingList(
                        stories: _stories,
                        currentUser: currentUser.id.isEmpty
                            ? null
                            : currentUser,
                        users: storyUsers,
                        showAddStory: false,
                        showCurrentUserStory: false,
                        onStoryAdded: (_) {},
                        onStoriesSeen: _markStoriesSeen,
                        onStoryDeleted: (_) async {},
                        onStoryLongPress: _openChatWithUser,
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
                  final ChatThreadModel thread = inbox[index];
                  final UserModel user = thread.user;
                  final MessageModel seedMessage =
                      thread.lastMessageModel ??
                      MessageModel(
                        id: thread.id,
                        chatId: thread.chatId,
                        senderId: user.id,
                        text: thread.lastMessage,
                        timestamp: DateTime.now(),
                        read: thread.unreadCount == 0,
                      );

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Dismissible(
                      key: ValueKey(thread.chatId),
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
                          children: <Widget>[
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
                        _controller.deleteConversation(thread.chatId);
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
                                initialMessage: seedMessage,
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showChatOptions(thread.chatId, user.name);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.hexFFF0F0F0),
                          ),
                          child: Row(
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
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
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _timeLabel(seedMessage.timestamp),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                _controller.unreadCount(
                                                      thread.chatId,
                                                    ) >
                                                    0
                                                ? AppColors.hexFF00ACC1
                                                : AppColors.grey,
                                            fontWeight:
                                                _controller.unreadCount(
                                                      thread.chatId,
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
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            thread.lastMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  _controller.unreadCount(
                                                        thread.chatId,
                                                      ) >
                                                      0
                                                  ? AppColors.black87
                                                  : AppColors.grey,
                                              fontWeight:
                                                  _controller.unreadCount(
                                                        thread.chatId,
                                                      ) >
                                                      0
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (_controller.unreadCount(
                                              thread.chatId,
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
                                              '${_controller.unreadCount(thread.chatId)}',
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
                                    _controller.togglePinned(thread.chatId);
                                  } else if (value == 'archive') {
                                    _controller.toggleArchived(thread.chatId);
                                  } else if (value == 'mute') {
                                    AppGet.snackbar(
                                      'Mute',
                                      '${user.name} conversation muted',
                                    );
                                  } else if (value == 'settings') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ChatSettingsScreen(
                                          chatId: thread.chatId,
                                          title: user.name,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) =>
                                    const <PopupMenuEntry<String>>[
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
          children: <Widget>[
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

  List<UserModel> _storyUsers({
    required UserModel currentUser,
    required List<UserModel> conversationUsers,
  }) {
    return <String, UserModel>{
      if (currentUser.id.isNotEmpty) currentUser.id: currentUser,
      for (final UserModel user in conversationUsers) user.id: user,
      for (final StoryModel story in _stories)
        if (story.author != null)
          story.author!.id: story.author!
        else if (story.userId.trim().isNotEmpty)
          story.userId: UserModel(
            id: story.userId,
            name: 'Story',
            username: story.userId,
            avatar: 'https://placehold.co/120x120',
            bio: '',
            role: currentUser.role,
            followers: 0,
            following: 0,
          ),
    }.values.toList(growable: false);
  }

  void _markStoriesSeen(List<String> storyIds) {
    final Set<String> ids = storyIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet();
    if (ids.isEmpty) {
      return;
    }
    setState(() {
      _stories = _stories
          .map(
            (StoryModel story) =>
                ids.contains(story.id) ? story.copyWith(seen: true) : story,
          )
          .toList(growable: false);
    });
  }

  void _openChatWithUser(UserModel user) {
    if (_isOpeningStoryReply) {
      return;
    }
    setState(() => _isOpeningStoryReply = true);
    _chatRepository
        .createThread(user.id)
        .then((ChatThreadModel thread) {
          if (!mounted) {
            return;
          }
          final MessageModel seedMessage =
              thread.lastMessageModel ??
              _initialMessageFor(user, thread.chatId);
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChatDetailScreen(
                user: thread.user.id.isNotEmpty ? thread.user : user,
                initialMessage: seedMessage,
              ),
            ),
          );
        })
        .catchError((_) {
          AppGet.snackbar('Chat', 'Unable to open chat right now');
        })
        .whenComplete(() {
          if (mounted) {
            setState(() => _isOpeningStoryReply = false);
          }
        });
  }

  MessageModel _initialMessageFor(UserModel user, String chatId) {
    final String userId = user.id.trim().isEmpty ? user.username : user.id;
    return MessageModel(
      id: 'story_msg_${DateTime.now().microsecondsSinceEpoch}',
      chatId: chatId,
      senderId: userId,
      text: 'Reply to story',
      timestamp: DateTime.now(),
      read: true,
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
          actions: <Widget>[
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
}
