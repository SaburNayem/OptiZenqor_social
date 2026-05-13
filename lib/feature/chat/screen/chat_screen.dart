import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/common_widget/error_state_view.dart';
import '../../../core/common_widget/app_avatar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/message_model.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/enums/user_role.dart';
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
  const ChatScreen({super.key, this.controller});

  final ChatController? controller;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _controller;
  late final bool _ownsController;
  final HomeFeedRepository _homeFeedRepository = HomeFeedRepository();
  final ChatRepository _chatRepository = ChatRepository();
  List<StoryModel> _stories = <StoryModel>[];
  bool _isLoadingStories = false;
  bool _isOpeningStoryReply = false;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ChatController();
    if (_controller.threads.isEmpty && !_controller.isLoading) {
      unawaited(_controller.loadChats());
    }
    _loadStories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _refreshScreen() async {
    await Future.wait<void>(<Future<void>>[
      _controller.loadChats(),
      _loadStories(),
    ]);
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
    final UserModel? currentUser = context
        .read<MainShellController>()
        .currentUser;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        titleSpacing: _isSearchOpen ? 0 : NavigationToolbar.kMiddleSpacing,
        title: _isSearchOpen
            ? Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.search, color: AppColors.grey, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search messages',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _closeSearch,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.grey,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              )
            : const Text('Chats'),
        actions: <Widget>[
          if (!_isSearchOpen)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearchOpen = true;
                });
              },
              icon: const Icon(Icons.search_rounded, color: AppColors.black87),
              tooltip: 'Search',
            ),
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
                child: AppAvatar(
                  imageUrl: currentUser?.avatar ?? '',
                  radius: 16,
                ),
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
            return RefreshIndicator(
              onRefresh: _refreshScreen,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ErrorStateView(
                      message:
                          _controller.state.errorMessage ??
                          'Unable to load messages',
                      onRetry: _controller.loadChats,
                    ),
                  ),
                ],
              ),
            );
          }

          final List<ChatThreadModel> inbox = _controller.inboxThreads;
          final List<ChatThreadModel> visibleInbox = _filteredInbox(inbox);
          final List<UserModel> conversationUsers = inbox
              .map((ChatThreadModel thread) => thread.user)
              .where((UserModel user) => user.id.isNotEmpty)
              .toList(growable: false);
          final List<UserModel> storyUsers = _storyUsers(
            currentUser: currentUser,
            conversationUsers: conversationUsers,
          );
          return RefreshIndicator(
            onRefresh: _refreshScreen,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 12),
                      if (_isLoadingStories)
                        const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        StoryRingList(
                          stories: _stories,
                          currentUser:
                              currentUser == null || currentUser.id.isEmpty
                              ? null
                              : currentUser,
                          users: storyUsers,
                          showAddStory: true,
                          showCurrentUserStory: false,
                          onStoryAdded: (_) {},
                          onStoriesSeen: _markStoriesSeen,
                          onStoryDeleted: (_) async {},
                          onStoryLongPress: _openChatWithUser,
                        ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final ChatThreadModel thread = visibleInbox[index];
                    final UserModel user = thread.user;
                    final int unreadCount = _controller.unreadCountForThread(
                      thread,
                    );
                    final MessageModel seedMessage =
                        thread.lastMessageModel ??
                        MessageModel(
                          id: thread.id,
                          chatId: thread.chatId,
                          senderId: user.id,
                          text: thread.lastMessage.trim(),
                          timestamp:
                              thread.lastMessageModel?.timestamp ??
                              DateTime.fromMillisecondsSinceEpoch(0),
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
                              Icon(
                                Icons.delete_outline,
                                color: AppColors.white,
                              ),
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
                            ).then((_) => _controller.loadChats());
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
                                    AppAvatar(
                                      imageUrl: user.avatar,
                                      radius: 28,
                                    ),
                                    Positioned(
                                      right: 2,
                                      bottom: 2,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: user.isOnline == true
                                              ? AppColors.hexFF4CAF50
                                              : AppColors.grey400,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_controller.isMuted(thread.chatId))
                                      Positioned(
                                        left: -2,
                                        bottom: -2,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.volume_off_outlined,
                                            size: 12,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              color: unreadCount > 0
                                                  ? AppColors.hexFF00ACC1
                                                  : AppColors.grey,
                                              fontWeight: unreadCount > 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      if (_presenceLabel(
                                            thread,
                                            user,
                                          ) !=
                                          null) ...<Widget>[
                                        Text(
                                          _presenceLabel(thread, user)!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _controller.isThreadTyping(
                                                  thread.chatId,
                                                )
                                                ? AppColors.hexFF00ACC1
                                                : user.isOnline == true
                                                ? AppColors.hexFF00ACC1
                                                : AppColors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              _threadPreviewText(
                                                thread,
                                                currentUserId:
                                                    currentUser?.id ?? '',
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: unreadCount > 0
                                                    ? AppColors.black87
                                                    : AppColors.grey,
                                                fontWeight: unreadCount > 0
                                                    ? FontWeight.w500
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (unreadCount > 0)
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
                                                '$unreadCount',
                                                style: const TextStyle(
                                                  color: AppColors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          else if (_threadStatusLabel(
                                                thread,
                                                currentUserId:
                                                    currentUser?.id ?? '',
                                              ) !=
                                              null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              child: Text(
                                                _threadStatusLabel(
                                                  thread,
                                                  currentUserId:
                                                      currentUser?.id ?? '',
                                                )!,
                                                style: const TextStyle(
                                                  color: AppColors.grey,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
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
                                      final bool nextMuted = !_controller
                                          .isMuted(thread.chatId);
                                      _controller.toggleMuted(thread.chatId);
                                      AppGet.snackbar(
                                        'Chat',
                                        nextMuted
                                            ? '${user.name} conversation muted'
                                            : '${user.name} conversation unmuted',
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
                  }, childCount: visibleInbox.length),
                ),
                if (visibleInbox.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 40),
                      child: Center(
                        child: Text(
                          'No chats yet. Start with a story or open a new conversation.',
                          style: TextStyle(color: AppColors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<ChatThreadModel> _filteredInbox(List<ChatThreadModel> inbox) {
    final String query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return inbox;
    }
    return inbox
        .where((ChatThreadModel thread) {
          final UserModel user = thread.user;
          return user.name.toLowerCase().contains(query) ||
              user.username.toLowerCase().contains(query) ||
              thread.lastMessage.toLowerCase().contains(query) ||
              thread.title.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  String? _presenceLabel(ChatThreadModel thread, UserModel user) {
    if (_controller.isThreadTyping(thread.chatId)) {
      return 'Typing...';
    }
    if (user.isOnline == true) {
      return 'Active now';
    }
    final DateTime? lastSeen = user.lastSeen;
    if (lastSeen == null) {
      return null;
    }
    final Duration difference = DateTime.now().difference(lastSeen);
    if (difference.inMinutes < 1) {
      return 'Active just now';
    }
    if (difference.inHours < 1) {
      return 'Active ${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return 'Active ${difference.inHours}h ago';
    }
    return 'Active ${difference.inDays}d ago';
  }

  void _closeSearch() {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchController.clear();
      _isSearchOpen = false;
    });
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
                final bool nextMuted = !_controller.isMuted(chatId);
                _controller.toggleMuted(chatId);
                AppGet.snackbar(
                  'Chat',
                  nextMuted
                      ? '$name conversation muted'
                      : '$name conversation unmuted',
                );
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
    required UserModel? currentUser,
    required List<UserModel> conversationUsers,
  }) {
    return <String, UserModel>{
      if (currentUser != null && currentUser.id.isNotEmpty)
        currentUser.id: currentUser,
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
            role: currentUser?.role ?? UserRole.guest,
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
    if (timestamp.millisecondsSinceEpoch <= 0) {
      return '';
    }
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }
    return '${difference.inDays}d';
  }

  String _threadPreviewText(
    ChatThreadModel thread, {
    required String currentUserId,
  }) {
    final MessageModel? lastMessage = thread.lastMessageModel;
    final String body = _messagePreview(lastMessage, fallback: thread.lastMessage);
    if (body.isEmpty) {
      return 'No messages yet';
    }
    final bool isMine =
        lastMessage != null &&
        currentUserId.isNotEmpty &&
        lastMessage.senderId == currentUserId;
    return isMine ? 'You: $body' : body;
  }

  String? _threadStatusLabel(
    ChatThreadModel thread, {
    required String currentUserId,
  }) {
    final MessageModel? lastMessage = thread.lastMessageModel;
    if (lastMessage == null) {
      return null;
    }
    final bool isMine =
        currentUserId.isNotEmpty && lastMessage.senderId == currentUserId;
    if (isMine) {
      if (lastMessage.read) {
        return 'Seen';
      }
      return thread.user.isOnline == true ? 'Delivered' : 'Sent';
    }
    return null;
  }

  String _messagePreview(MessageModel? message, {required String fallback}) {
    if (message == null) {
      return fallback.trim();
    }
    final String text = message.text.trim();
    if (text.isNotEmpty) {
      return text;
    }
    switch (message.kind) {
      case 'image':
      case 'gallery':
      case 'camera':
      case 'photo':
        return 'Photo';
      case 'audio':
      case 'voice':
        return 'Audio message';
      case 'file':
      case 'document':
        return 'Attachment';
      case 'location':
        return 'Location';
      case 'contact':
        return 'Contact';
      default:
        return (message.mediaPath ?? '').trim().isNotEmpty
            ? 'Attachment'
            : fallback.trim();
    }
  }
}
