import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import '../../../core/data/models/message_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service/upload_service.dart';
import '../../../core/socket/socket_service.dart';
import '../../../core/common_widget/app_avatar.dart';
import '../../auth/repository/auth_repository.dart';
import '../../calls/screen/audio_call_screen.dart';
import '../../calls/screen/video_call_screen.dart';
import '../model/chat_thread_model.dart';
import '../repository/chat_repository.dart';
import 'chat_settings_screen.dart';
import '../../../core/constants/app_colors.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    required this.user,
    required this.initialMessage,
    super.key,
  });

  final UserModel user;
  final MessageModel initialMessage;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  static const List<double> _voiceWaveHeights = <double>[
    8,
    11,
    14,
    10,
    16,
    18,
    12,
    9,
    15,
    19,
    13,
    8,
    16,
    14,
    10,
    18,
    12,
    9,
    15,
    11,
  ];
  static const List<double> _recordWaveHeights = <double>[
    8,
    12,
    16,
    10,
    14,
    18,
    9,
    13,
    17,
    11,
    15,
    19,
    10,
    14,
    16,
    12,
    9,
    13,
  ];

  late final ValueNotifier<List<MessageModel>> _messages;
  final ChatRepository _chatRepository = ChatRepository();
  final AuthRepository _authRepository = AuthRepository();
  final UploadService _uploadService = UploadService();
  final SocketService _socketService = SocketService.instance;
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  late final ScrollController _scrollController;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Timer? _refreshTimer;
  Timer? _typingDebounceTimer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Timer? _recordTimer;

  bool _isTyping = false;
  bool _isRecording = false;
  bool _isLoadingMessages = true;
  bool _isSendingMessage = false;
  bool _isSearchOpen = false;
  bool _otherUserTyping = false;
  String _currentUserId = '';
  UserModel? _currentUser;
  late UserModel _chatUser;
  int _pendingIncomingCount = 0;
  Duration _recordDuration = Duration.zero;
  String? _recordingPath;
  String? _playingMessageId;
  String? _pendingAttachmentPath;
  String? _pendingAttachmentKind;
  String? _pendingAttachmentLabel;
  MessageModel? _replyingToMessage;
  MessageModel? _editingMessage;
  Duration _playbackProgress = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  List<double> _activeRecordWaveHeights = List<double>.filled(18, 8);

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    _scrollController = ScrollController()..addListener(_handleScrollChanged);
    _chatUser = widget.user;
    _messages = ValueNotifier<List<MessageModel>>(<MessageModel>[]);
    _messageController.addListener(_handleMessageChanged);
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    unawaited(_initializeChat());
    _positionSubscription = _audioPlayer.positionStream.listen((
      Duration value,
    ) {
      if (!mounted) {
        return;
      }
      setState(() {
        _playbackProgress = value;
      });
    });
    _durationSubscription = _audioPlayer.durationStream.listen((
      Duration? value,
    ) {
      if (!mounted || value == null) {
        return;
      }
      setState(() {
        _playbackDuration = value;
      });
    });
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      PlayerState state,
    ) {
      if (!mounted) {
        return;
      }
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _playingMessageId = null;
          _playbackProgress = Duration.zero;
          _playbackDuration = Duration.zero;
        });
        unawaited(_audioPlayer.stop());
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _typingDebounceTimer?.cancel();
    _recordTimer?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _amplitudeSubscription?.cancel();
    _messageController
      ..removeListener(_handleMessageChanged)
      ..dispose();
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScrollChanged)
      ..dispose();
    _messages.dispose();
    unawaited(
      _socketService.send('thread.leave', data: <String, dynamic>{
        'threadId': widget.initialMessage.chatId,
      }).catchError((_) {}),
    );
    unawaited(_audioPlayer.dispose());
    unawaited(_audioRecorder.dispose());
    super.dispose();
  }

  Future<void> _initializeChat() async {
    final UserModel? currentUser = await _authRepository.currentUser();
    _currentUser = currentUser;
    _currentUserId = currentUser?.id ?? '';
    await _socketService.connect().catchError((_) => false);
    unawaited(
      _socketService.send('thread.join', data: <String, dynamic>{
        'threadId': widget.initialMessage.chatId,
      }).catchError((_) {}),
    );
    await _loadMessages();
    await _syncPresence();
    await _markThreadRead();
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _isSendingMessage || _isRecording) {
        return;
      }
      unawaited(_loadMessages(showLoader: false));
      unawaited(_syncPresence());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: _isSearchOpen
            ? Container(
                height: 42,
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
                        decoration: const InputDecoration(
                          hintText: 'Search this chat',
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
            : Row(
                children: [
                  Stack(
                    children: [
                      const SizedBox.shrink(),
                      AppAvatar(imageUrl: _chatUser.avatar, radius: 18),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _chatUser.isOnline == true
                                ? AppColors.hexFF4CAF50
                                : AppColors.grey400,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 1.5,
                            ),
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
                        _chatUser.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black87,
                        ),
                      ),
                      if (_headerStatusText != null)
                        Text(
                          _headerStatusText!,
                          style: TextStyle(
                            fontSize: 12,
                            color: _otherUserTyping || _chatUser.isOnline == true
                                ? AppColors.hexFF00ACC1
                                : AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
        actions: [
          if (!_isSearchOpen) ...<Widget>[
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AudioCallScreen(
                      name: _chatUser.name,
                      avatarUrl: _chatUser.avatar,
                      recipientId: _chatUser.id,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.call_outlined, color: AppColors.grey),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VideoCallScreen(
                      name: _chatUser.name,
                      avatarUrl: _chatUser.avatar,
                      recipientId: _chatUser.id,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.videocam_outlined, color: AppColors.grey),
            ),
          ],
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'search') {
                setState(() {
                  _isSearchOpen = true;
                });
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ChatSettingsScreen(
                    chatId: widget.initialMessage.chatId,
                    title: _chatUser.name,
                  ),
                ),
              );
            },
            itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'search',
                child: Text('Search messages'),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Text('Chat settings'),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: AppColors.grey),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 0.5),
          Expanded(
            child: _isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : ValueListenableBuilder<List<MessageModel>>(
                    valueListenable: _messages,
                    builder:
                        (BuildContext context, List<MessageModel> messages, _) {
                          final List<MessageModel> visibleMessages =
                              _visibleMessages(messages);
                          return Stack(
                            children: <Widget>[
                              ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                                itemCount: visibleMessages.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == 0) {
                                    return Center(
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 24),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.grey100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Today',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.grey500,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final MessageModel message =
                                      visibleMessages[index - 1];
                              final bool isMe = _currentUserId.isNotEmpty
                                  ? message.senderId == _currentUserId
                                  : message.senderId == 'me';
                              final bool showAvatar =
                                  !isMe &&
                                  (index == 1 ||
                                      (_currentUserId.isNotEmpty
                                          ? visibleMessages[index - 2].senderId ==
                                                _currentUserId
                                          : visibleMessages[index - 2].senderId ==
                                                'me'));

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: isMe
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (!isMe)
                                          SizedBox(
                                            width: 40,
                                            child: showAvatar
                                                ? AppAvatar(
                                                    imageUrl:
                                                        widget.user.avatar,
                                                    radius: 16,
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                        if (!isMe) const SizedBox(width: 8),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.7,
                                          ),
                                          child: _buildInteractiveMessageBubble(
                                            message,
                                            isMe,
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
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          if (message.starred) ...<Widget>[
                                            const Icon(
                                              Icons.push_pin,
                                              size: 12,
                                              color: AppColors.grey400,
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            DateFormat(
                                              'h:mm a',
                                            ).format(message.timestamp),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.grey400,
                                            ),
                                          ),
                                          if (isMe &&
                                              _messageStatusLabel(message) !=
                                                  null) ...<Widget>[
                                            const SizedBox(width: 6),
                                            Text(
                                              _messageStatusLabel(message)!,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: message.read
                                                    ? AppColors.hexFF00ACC1
                                                    : AppColors.grey400,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                                },
                              ),
                              if (_shouldShowJumpToBottomButton)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 18,
                                  child: Center(
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: <Widget>[
                                        Material(
                                          color: AppColors.hexFF26C6DA,
                                          shape: const CircleBorder(),
                                          elevation: 4,
                                          child: InkWell(
                                            onTap: _jumpToBottom,
                                            customBorder: const CircleBorder(),
                                            child: const Padding(
                                              padding: EdgeInsets.all(14),
                                              child: Icon(
                                                Icons.south_rounded,
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (_pendingIncomingCount > 0)
                                          Positioned(
                                            top: -6,
                                            right: -6,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.black87,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                border: Border.all(
                                                  color: AppColors.white,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Text(
                                                '$_pendingIncomingCount',
                                                style: const TextStyle(
                                                  color: AppColors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                  ),
          ),
          _buildMessageComposer(context),
        ],
      ),
    );
  }

  Future<void> _loadMessages({bool showLoader = true}) async {
    if (showLoader && mounted) {
      setState(() {
        _isLoadingMessages = true;
      });
    }
    try {
      final List<MessageModel> previousMessages = List<MessageModel>.from(
        _messages.value,
      );
      final List<MessageModel> remoteMessages = await _chatRepository
          .fetchMessages(widget.initialMessage.chatId);
      if (!mounted) {
        return;
      }
      final List<MessageModel> mergedMessages = _mergeMessages(remoteMessages);
      final int newlyReceivedCount = _countNewIncomingMessages(
        previousMessages,
        mergedMessages,
      );
      _messages.value = mergedMessages;
      _afterMessagesUpdated(
        forceScrollToBottom:
            showLoader || _isNearBottom || previousMessages.isEmpty,
        newlyReceivedCount: newlyReceivedCount,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (_messages.value.isEmpty) {
        _messages.value = _seedInitialMessages();
        _afterMessagesUpdated(forceScrollToBottom: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMessages = false;
        });
      }
    }
  }

  Widget _buildMessageComposer(BuildContext context) {
    final bool showSend =
        _isTyping || _isRecording || _pendingAttachmentPath != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingToMessage != null || _editingMessage != null) ...<Widget>[
            _buildComposerActionBanner(),
            const SizedBox(height: 10),
          ],
          if (_pendingAttachmentPath != null) ...<Widget>[
            _buildPendingAttachmentPreview(),
            const SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _isSendingMessage
                    ? null
                    : () => _showAttachmentSheet(context),
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.grey,
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _isRecording
                      ? _buildRecordingBar()
                      : _buildTextComposerField(),
                ),
              ),
              const SizedBox(width: 8),
              if (showSend)
                IconButton(
                  onPressed: _isSendingMessage ? null : _sendCurrentPayload,
                  icon: Icon(
                    Icons.send_rounded,
                    color: _isSendingMessage
                        ? AppColors.grey400
                        : AppColors.hexFF26C6DA,
                  ),
                )
              else
                IconButton(
                  onPressed: _isSendingMessage ? null : _toggleVoiceRecording,
                  icon: const Icon(
                    Icons.mic_none_rounded,
                    color: AppColors.grey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposerField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey100),
      ),
      child: TextField(
        controller: _messageController,
        minLines: 1,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Type a message...',
          hintStyle: TextStyle(color: AppColors.grey, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildPendingAttachmentPreview() {
    final String kind = _pendingAttachmentKind ?? 'document';
    final String label = _pendingAttachmentLabel ?? 'Attachment';
    final String path = _pendingAttachmentPath!;
    final bool isImage = kind == 'gallery' || kind == 'camera';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isImage
                ? Image.file(
                    File(path),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: AppColors.white,
                    alignment: Alignment.center,
                    child: Icon(
                      _attachmentIcon(kind),
                      color: AppColors.hexFF26C6DA,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  isImage ? 'Photo ready to send' : 'Attachment ready to send',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearPendingAttachment,
            icon: const Icon(Icons.close_rounded, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildComposerActionBanner() {
    final MessageModel? activeMessage = _editingMessage ?? _replyingToMessage;
    final bool isEditing = _editingMessage != null;
    if (activeMessage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.hexFF26C6DA,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  isEditing ? 'Editing message' : 'Replying to message',
                  style: const TextStyle(
                    color: AppColors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _messagePreviewText(activeMessage),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearComposerActionState,
            icon: const Icon(Icons.close_rounded, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveMessageBubble(MessageModel message, bool isMe) {
    return Dismissible(
      key: ValueKey<String>('reply-${message.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        _startReply(message);
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(
          Icons.reply_rounded,
          color: AppColors.hexFF26C6DA,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => _showMessageActions(message, isMe),
        child: _buildMessageBubble(message, isMe),
      ),
    );
  }

  Widget? _buildReplySnippet(MessageModel message, bool isMe) {
    final String replyId = (message.replyToMessageId ?? '').trim();
    if (replyId.isEmpty) {
      return null;
    }
    MessageModel? repliedMessage;
    for (final MessageModel item in _messages.value) {
      if (item.id == replyId) {
        repliedMessage = item;
        break;
      }
    }
    if (repliedMessage == null) {
      return null;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.white.withValues(alpha: 0.16)
            : AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Reply',
            style: TextStyle(
              color: isMe ? AppColors.white : AppColors.hexFF26C6DA,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _messagePreviewText(repliedMessage),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isMe
                  ? AppColors.white.withValues(alpha: 0.9)
                  : AppColors.black87,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final BoxDecoration decoration = BoxDecoration(
      color: isMe ? AppColors.hexFF26C6DA : AppColors.grey50,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomLeft: Radius.circular(isMe ? 20 : 4),
        bottomRight: Radius.circular(isMe ? 4 : 20),
      ),
      border: isMe ? null : Border.all(color: AppColors.grey100),
    );

    switch (message.kind) {
      case 'voice':
        return _buildVoiceBubble(message, isMe, decoration);
      case 'gallery':
      case 'image':
      case 'photo':
        return _buildImageBubble(message, isMe, decoration);
      case 'camera':
        return _isImagePath(message.mediaPath)
            ? _buildImageBubble(message, isMe, decoration)
            : _buildAttachmentBubble(message, isMe, decoration);
      case 'document':
      case 'file':
      case 'video':
      case 'location':
      case 'contact':
      case 'audio':
        return _buildAttachmentBubble(message, isMe, decoration);
      default:
        if ((message.mediaPath ?? '').trim().isNotEmpty) {
          return _isImagePath(message.mediaPath)
              ? _buildImageBubble(message, isMe, decoration)
              : _buildAttachmentBubble(message, isMe, decoration);
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: decoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (_buildReplySnippet(message, isMe) case final Widget replySnippet)
                replySnippet,
              Text(
                message.text,
                style: TextStyle(
                  color: isMe ? AppColors.white : AppColors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
    }
  }

  List<MessageModel> _visibleMessages(List<MessageModel> source) {
    final String query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return source;
    }
    return source.where((MessageModel message) {
      return _messagePreviewText(message).toLowerCase().contains(query);
    }).toList(growable: false);
  }

  Widget _buildAttachmentBubble(
    MessageModel message,
    bool isMe,
    BoxDecoration decoration,
  ) {
    return InkWell(
      onTap: () => _handleAttachmentTap(message),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: decoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (_buildReplySnippet(message, isMe) case final Widget replySnippet)
              replySnippet,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _attachmentIcon(message.kind),
                  color: isMe ? AppColors.white : AppColors.hexFF26C6DA,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    _messagePreviewText(message),
                    style: TextStyle(
                      color: isMe ? AppColors.white : AppColors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBubble(
    MessageModel message,
    bool isMe,
    BoxDecoration decoration,
  ) {
    final String? path = message.mediaPath;
    final bool hasCaption = message.text.trim().isNotEmpty;

    return InkWell(
      onTap: () => _handleAttachmentTap(message),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: decoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (_buildReplySnippet(message, isMe) case final Widget replySnippet)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: replySnippet,
              ),
            if (path != null && path.isNotEmpty)
              _buildImagePreview(path)
            else
              Container(
                width: 220,
                height: 180,
                color: isMe
                    ? AppColors.white.withValues(alpha: 0.18)
                    : AppColors.grey100,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: isMe ? AppColors.white : AppColors.grey,
                ),
              ),
            if (hasCaption)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? AppColors.white : AppColors.black87,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String path) {
    final bool localFile = File(path).existsSync();
    if (localFile) {
      return Image.file(File(path), width: 220, height: 180, fit: BoxFit.cover);
    }
    return Image.network(
      path,
      width: 220,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 220,
          height: 180,
          color: AppColors.grey100,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, color: AppColors.grey),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return Container(
          width: 220,
          height: 180,
          color: AppColors.grey50,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }

  Widget _buildVoiceBubble(
    MessageModel message,
    bool isMe,
    BoxDecoration decoration,
  ) {
    final bool isPlaying = _playingMessageId == message.id;
    final Duration total = _voiceDurationForMessage(message);
    final Duration current = isPlaying ? _playbackProgress : Duration.zero;
    final double progress = total.inMilliseconds == 0
        ? 0
        : current.inMilliseconds / total.inMilliseconds;
    final bool hasVoiceFile =
        message.mediaPath != null && File(message.mediaPath!).existsSync();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (_buildReplySnippet(message, isMe) case final Widget replySnippet)
            replySnippet,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: hasVoiceFile ? () => _toggleVoicePlayback(message) : null,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.white.withValues(alpha: 0.2)
                        : AppColors.hexFF26C6DA.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: hasVoiceFile
                        ? (isMe ? AppColors.white : AppColors.hexFF26C6DA)
                        : AppColors.grey400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: List<Widget>.generate(_voiceWaveHeights.length, (
                    int index,
                  ) {
                    final bool active =
                        index / _voiceWaveHeights.length <= progress.clamp(0, 1) &&
                        isPlaying;
                    return Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: 3,
                        height: _voiceWaveHeights[index],
                        decoration: BoxDecoration(
                          color: active
                              ? (isMe ? AppColors.white : AppColors.hexFF26C6DA)
                              : (isMe
                                    ? AppColors.white.withValues(alpha: 0.45)
                                    : AppColors.grey400),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _formatRecordDuration(isPlaying ? current : total),
                style: TextStyle(
                  color: isMe ? AppColors.white : AppColors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingBar() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _stopRecording(resetOnly: true),
            child: const Icon(
              Icons.stop_circle_outlined,
              color: AppColors.hexFF26C6DA,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: List<Widget>.generate(_activeRecordWaveHeights.length, (
                int index,
              ) {
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Container(
                    width: 3,
                    height: _activeRecordWaveHeights[index],
                    decoration: BoxDecoration(
                      color: AppColors.hexFF26C6DA,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatRecordDuration(_recordDuration),
            style: const TextStyle(
              color: AppColors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMessageChanged() {
    final bool next = _messageController.text.trim().isNotEmpty;
    if (next == _isTyping) {
      return;
    }
    setState(() {
      _isTyping = next;
      if (_isTyping && _isRecording) {
        unawaited(_stopRecording(resetOnly: true));
      }
    });
    _typingDebounceTimer?.cancel();
    unawaited(_setTypingState(next));
    if (next) {
      _typingDebounceTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted || _messageController.text.trim().isNotEmpty) {
          return;
        }
        unawaited(_setTypingState(false));
      });
    }
  }

  Future<void> _toggleVoiceRecording() async {
    if (_isRecording) {
      await _stopRecording(resetOnly: true);
      return;
    }

    final bool hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }

    final String recordingPath = _buildVoiceFilePath();

    try {
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: recordingPath,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start voice recording.')),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    FocusScope.of(context).unfocus();
    _messageController.clear();
    setState(() {
      _isTyping = false;
      _isRecording = true;
      _recordDuration = Duration.zero;
      _recordingPath = recordingPath;
      _activeRecordWaveHeights = List<double>.from(_recordWaveHeights);
    });

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isRecording) {
        return;
      }
      setState(() {
        _recordDuration += const Duration(seconds: 1);
      });
    });
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .listen((Amplitude amplitude) {
          if (!mounted || !_isRecording) {
            return;
          }
          final double mappedHeight = _mapAmplitudeToHeight(amplitude.current);
          setState(() {
            _activeRecordWaveHeights = <double>[
              ..._activeRecordWaveHeights.skip(1),
              mappedHeight,
            ];
          });
        });
  }

  Future<void> _stopRecording({bool resetOnly = false}) async {
    _recordTimer?.cancel();
    _amplitudeSubscription?.cancel();

    String? recordedPath;
    if (await _audioRecorder.isRecording()) {
      recordedPath = await _audioRecorder.stop();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isRecording = false;
      if (!resetOnly && (recordedPath?.isNotEmpty ?? false)) {
        _recordingPath = recordedPath;
      } else if (resetOnly) {
        _recordingPath = null;
      }
      if (resetOnly) {
        _recordDuration = Duration.zero;
        _activeRecordWaveHeights = List<double>.filled(18, 8);
      }
    });
  }

  Future<void> _sendCurrentPayload() async {
    if (_editingMessage != null && !_isRecording) {
      final String text = _messageController.text.trim();
      if (text.isEmpty || _isSendingMessage) {
        return;
      }
      final MessageModel message = _editingMessage!;
      _messageController.clear();
      await _editMessageOnBackend(message, text);
      return;
    }

    if (_isRecording) {
      final String durationText = _formatRecordDuration(_recordDuration);
      final String? voicePath = await _finishVoiceRecordingForSend();
      if (voicePath == null) {
        return;
      }
      await _sendMessageToBackend(
        text: durationText,
        kind: 'voice',
        localMediaPath: voicePath,
      );
      return;
    }

    final String text = _messageController.text.trim();
    final String? attachmentPath = _pendingAttachmentPath;
    final String attachmentKind = _pendingAttachmentKind ?? 'text';
    final String? attachmentLabel = _pendingAttachmentLabel;
    if ((text.isEmpty && attachmentPath == null) || _isSendingMessage) {
      return;
    }
    _messageController.clear();
    await _sendMessageToBackend(
      text: text,
      kind: attachmentPath == null ? 'text' : attachmentKind,
      localMediaPath: attachmentPath,
      fallbackLabel: attachmentLabel,
      replyToMessageId: _replyingToMessage?.id,
    );
  }

  Future<String?> _finishVoiceRecordingForSend() async {
    _recordTimer?.cancel();
    String? recordedPath = _recordingPath;

    if (await _audioRecorder.isRecording()) {
      recordedPath = await _audioRecorder.stop();
    }

    if (!mounted) {
      return null;
    }

    if (recordedPath == null || recordedPath.isEmpty) {
      setState(() {
        _isRecording = false;
        _recordDuration = Duration.zero;
        _recordingPath = null;
        _activeRecordWaveHeights = List<double>.filled(18, 8);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice message could not be saved.')),
      );
      return null;
    }

    setState(() {
      _isRecording = false;
      _recordDuration = Duration.zero;
      _recordingPath = null;
      _activeRecordWaveHeights = List<double>.filled(18, 8);
    });
    return recordedPath;
  }

  MessageModel _appendLocalMessage(
    String text, {
    String kind = 'text',
    String? mediaPath,
  }) {
    final MessageModel message = MessageModel(
      id: 'm_${DateTime.now().microsecondsSinceEpoch}',
      chatId: widget.initialMessage.chatId,
      senderId: _currentUserId.isEmpty ? 'me' : _currentUserId,
      text: text,
      timestamp: DateTime.now(),
      read: true,
      kind: kind,
      mediaPath: mediaPath,
      deliveryState: 'sending',
    );
    _messages.value = <MessageModel>[..._messages.value, message];
    return message;
  }

  void _replaceMessage(String messageId, MessageModel next) {
    _messages.value = _messages.value
        .map((MessageModel item) => item.id == messageId ? next : item)
        .toList(growable: false);
  }

  Future<void> _sendMessageToBackend({
    required String text,
    required String kind,
    String? localMediaPath,
    String? fallbackLabel,
    String? replyToMessageId,
  }) async {
    final String normalizedText = text.trim();
    final String normalizedKind = kind.trim().toLowerCase();
    final String persistedText = normalizedText;
    final String optimisticText = normalizedText;
    final MessageModel optimistic = _appendLocalMessage(
      optimisticText,
      kind: kind,
      mediaPath: localMediaPath,
    );
    setState(() {
      _isSendingMessage = true;
    });

    try {
      _UploadedChatAttachment? uploadedAttachment;
      if ((localMediaPath ?? '').trim().isNotEmpty) {
        uploadedAttachment = await _uploadChatAttachment(
          localPath: localMediaPath!.trim(),
          kind: normalizedKind,
        );
      }
      final MessageModel sent = await _chatRepository.sendMessage(
        chatId: widget.initialMessage.chatId,
        senderId: _currentUserId,
        text: persistedText,
        kind: kind,
        mediaUrl: uploadedAttachment?.remotePath,
        attachmentName: uploadedAttachment?.name ?? fallbackLabel,
        mimeType: uploadedAttachment?.mimeType,
        replyToMessageId: replyToMessageId,
      );
      if (!mounted) {
        return;
      }
      _replaceMessage(
        optimistic.id,
        sent.copyWith(
          deliveryState: sent.deliveryState.isEmpty
              ? 'sent'
              : sent.deliveryState,
          mediaPath: (sent.mediaPath ?? '').trim().isNotEmpty
              ? sent.mediaPath
              : (uploadedAttachment?.remotePath ?? localMediaPath),
          kind: sent.kind.isEmpty ? kind : sent.kind,
          text: sent.text.trim().isNotEmpty ? sent.text : optimisticText,
        ),
      );
      _clearPendingAttachment();
      _clearComposerActionState();
      _afterMessagesUpdated(forceScrollToBottom: true);
      await _markThreadRead();
      unawaited(_loadMessages(showLoader: false));
    } catch (error) {
      if (!mounted) {
        return;
      }
      _replaceMessage(
        optimistic.id,
        optimistic.copyWith(deliveryState: 'failed'),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(_chatErrorMessage(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  void _startReply(MessageModel message) {
    FocusScope.of(context).unfocus();
    setState(() {
      _editingMessage = null;
      _replyingToMessage = message;
    });
  }

  void _startEditing(MessageModel message) {
    setState(() {
      _replyingToMessage = null;
      _editingMessage = message;
      _pendingAttachmentPath = null;
      _pendingAttachmentKind = null;
      _pendingAttachmentLabel = null;
    });
    _messageController
      ..text = message.text
      ..selection = TextSelection.collapsed(offset: message.text.length);
  }

  void _clearComposerActionState() {
    if (!mounted) {
      return;
    }
    final bool wasEditing = _editingMessage != null;
    setState(() {
      _replyingToMessage = null;
      _editingMessage = null;
    });
    if (wasEditing) {
      _messageController.clear();
    }
  }

  Future<void> _showMessageActions(MessageModel message, bool isMe) async {
    final String? action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        final List<({String value, IconData icon, String label})> actions =
            <({String value, IconData icon, String label})>[
              (value: 'reply', icon: Icons.reply_rounded, label: 'Reply'),
              (
                value: 'pin',
                icon: message.starred
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                label: message.starred ? 'Unpin' : 'Pin',
              ),
              (value: 'forward', icon: Icons.forward_rounded, label: 'Forward'),
              if (isMe)
                (value: 'edit', icon: Icons.edit_outlined, label: 'Edit'),
              if (isMe)
                (
                  value: 'delete',
                  icon: Icons.delete_outline,
                  label: 'Delete',
                ),
            ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: actions.map((({String value, IconData icon, String label}) action) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    action.icon,
                    color: action.value == 'delete'
                        ? Colors.redAccent
                        : AppColors.black87,
                  ),
                  title: Text(
                    action.label,
                    style: TextStyle(
                      color: action.value == 'delete'
                          ? Colors.redAccent
                          : AppColors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(action.value),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    switch (action) {
      case 'reply':
        _startReply(message);
        return;
      case 'edit':
        _startEditing(message);
        return;
      case 'delete':
        await _deleteMessageOnBackend(message);
        return;
      case 'pin':
        await _toggleMessagePinOnBackend(message);
        return;
      case 'forward':
        await _forwardMessageToThread(message);
        return;
    }
  }

  Future<void> _editMessageOnBackend(MessageModel message, String text) async {
    setState(() {
      _isSendingMessage = true;
    });
    try {
      final MessageModel edited = await _chatRepository.editMessage(
        chatId: widget.initialMessage.chatId,
        messageId: message.id,
        text: text,
      );
      if (!mounted) {
        return;
      }
      _replaceMessage(message.id, edited);
      _clearComposerActionState();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to edit message.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  Future<void> _deleteMessageOnBackend(MessageModel message) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete message?'),
              content: const Text('This message will be removed from the chat.'),
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
        ) ??
        false;
    if (!confirmed) {
      return;
    }

    try {
      await _chatRepository.deleteMessage(
        chatId: widget.initialMessage.chatId,
        messageId: message.id,
      );
      if (!mounted) {
        return;
      }
      _messages.value = _messages.value
          .where((MessageModel item) => item.id != message.id)
          .toList(growable: false);
      if (_editingMessage?.id == message.id || _replyingToMessage?.id == message.id) {
        _clearComposerActionState();
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete message.')),
      );
    }
  }

  Future<void> _toggleMessagePinOnBackend(MessageModel message) async {
    try {
      final MessageModel updated = await _chatRepository.toggleMessagePin(
        chatId: widget.initialMessage.chatId,
        messageId: message.id,
        value: !message.starred,
      );
      if (!mounted) {
        return;
      }
      _replaceMessage(message.id, updated);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to pin message.')),
      );
    }
  }

  Future<void> _forwardMessageToThread(MessageModel message) async {
    try {
      final List<ChatThreadModel> threads = await _chatRepository.fetchThreads();
      if (!mounted) {
        return;
      }
      final ChatThreadModel? target = await showModalBottomSheet<ChatThreadModel>(
        context: context,
        showDragHandle: true,
        builder: (BuildContext context) {
          final List<ChatThreadModel> available = threads
              .where((ChatThreadModel item) => item.chatId != widget.initialMessage.chatId)
              .toList(growable: false);
          if (available.isEmpty) {
            return const SafeArea(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No other conversations available to forward to.'),
              ),
            );
          }
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: available.map((ChatThreadModel thread) {
                return ListTile(
                  leading: AppAvatar(imageUrl: thread.user.avatar, radius: 18),
                  title: Text(thread.user.name),
                  subtitle: Text(
                    thread.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.of(context).pop(thread),
                );
              }).toList(),
            ),
          );
        },
      );
      if (target == null) {
        return;
      }
      await _chatRepository.forwardMessage(
        sourceChatId: widget.initialMessage.chatId,
        messageId: message.id,
        targetChatId: target.chatId,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Forwarded to ${target.user.name}.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to forward message.')),
      );
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) {
      return true;
    }
    return _scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <=
        80;
  }

  bool get _shouldShowJumpToBottomButton =>
      !_isLoadingMessages &&
      !_isNearBottom &&
      (_pendingIncomingCount > 0 || _messages.value.length > 8);

  void _handleScrollChanged() {
    if (!mounted) {
      return;
    }
    if (_isNearBottom && _pendingIncomingCount != 0) {
      setState(() {
        _pendingIncomingCount = 0;
      });
      unawaited(_markThreadRead());
    } else {
      setState(() {});
    }
  }

  void _afterMessagesUpdated({
    bool forceScrollToBottom = false,
    int newlyReceivedCount = 0,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (forceScrollToBottom) {
        _jumpToBottom(animated: false);
        return;
      }
      if (newlyReceivedCount > 0 && _isNearBottom) {
        _jumpToBottom(animated: false);
        return;
      }
      if (newlyReceivedCount > 0) {
        setState(() {
          _pendingIncomingCount += newlyReceivedCount;
        });
      } else {
        setState(() {});
      }
    });
  }

  int _countNewIncomingMessages(
    List<MessageModel> previous,
    List<MessageModel> current,
  ) {
    final Set<String> previousIds = previous
        .map((MessageModel item) => item.id)
        .where((String item) => item.isNotEmpty)
        .toSet();
    return current.where((MessageModel message) {
      return !previousIds.contains(message.id) &&
          message.senderId != _currentUserId &&
          !message.read;
    }).length;
  }

  Future<void> _jumpToBottom({bool animated = true}) async {
    if (!_scrollController.hasClients) {
      return;
    }
    final double target = _scrollController.position.maxScrollExtent;
    if (animated) {
      await _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
    if (mounted) {
      setState(() {
        _pendingIncomingCount = 0;
      });
    }
    await _markThreadRead();
  }

  List<MessageModel> _mergeMessages(List<MessageModel> remoteMessages) {
    final List<MessageModel> localPending = _messages.value
        .where(
          (MessageModel message) =>
              message.deliveryState == 'sending' ||
              message.deliveryState == 'failed',
        )
        .toList(growable: false);
    final List<MessageModel> merged = <MessageModel>[
      ...remoteMessages,
      ...localPending.where(
        (MessageModel local) => !remoteMessages.any(
          (MessageModel remote) =>
              remote.id == local.id || _looksLikeSameMessage(remote, local),
        ),
      ),
    ];
    merged.sort(
      (MessageModel a, MessageModel b) => a.timestamp.compareTo(b.timestamp),
    );
    return merged;
  }

  bool _looksLikeSameMessage(MessageModel remote, MessageModel local) {
    return remote.senderId == local.senderId &&
        remote.kind == local.kind &&
        remote.text.trim() == local.text.trim() &&
        remote.timestamp.difference(local.timestamp).inSeconds.abs() <= 10;
  }

  String? _messageStatusLabel(MessageModel message) {
    final String state = message.deliveryState.trim().toLowerCase();
    if (state == 'failed') {
      return 'Failed';
    }
    if (state == 'sending') {
      return 'Sending';
    }
    if (message.read) {
      return 'Seen';
    }
    if (_chatUser.isOnline == true) {
      return 'Delivered';
    }
    if (state == 'delivered' || state == 'read') {
      return 'Delivered';
    }
    if (state == 'sent') {
      return 'Sent';
    }
    return 'Sent';
  }

  Future<void> _markThreadRead() async {
    try {
      await _chatRepository.markThreadRead(widget.initialMessage.chatId);
    } catch (_) {
      return;
    }
  }

  Future<void> _setTypingState(bool isTyping) async {
    try {
      await _chatRepository.updateTypingPresence(
        threadId: widget.initialMessage.chatId,
        isTyping: isTyping,
      );
    } catch (_) {
      return;
    }
  }

  Future<void> _syncPresence() async {
    try {
      final Map<String, dynamic> snapshot = await _chatRepository
          .fetchPresenceSnapshot();
      final List<Map<String, dynamic>> users = _readMapList(snapshot['users']);
      final Map<String, dynamic>? userPresence = users
          .cast<Map<String, dynamic>?>()
          .firstWhere(
            (Map<String, dynamic>? item) =>
                item != null &&
                (item['userId'] ?? item['id'] ?? '').toString() == _chatUser.id,
            orElse: () => null,
          );
      final List<Map<String, dynamic>> threadStates = _readMapList(
        snapshot['threadStates'],
      );
      final Map<String, dynamic>? threadPresence = threadStates
          .cast<Map<String, dynamic>?>()
          .firstWhere(
            (Map<String, dynamic>? item) =>
                item != null &&
                (item['threadId'] ?? '').toString() ==
                    widget.initialMessage.chatId,
            orElse: () => null,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        if (userPresence != null) {
          _chatUser = _chatUser.copyWith(
            isOnline: _readBool(
              userPresence['isOnline'] ?? userPresence['online'],
            ),
            lastSeen: _readDateTime(userPresence['lastSeen']),
          );
        }
        _otherUserTyping =
            threadPresence != null &&
            _readStringList(
              threadPresence['typingUserIds'],
            ).contains(_chatUser.id);
      });
    } catch (_) {
      return;
    }
  }

  List<MessageModel> _seedInitialMessages() {
    final List<MessageModel> seeded = <MessageModel>[];
    if (widget.initialMessage.text.trim().isNotEmpty &&
        widget.initialMessage.timestamp.millisecondsSinceEpoch > 0) {
      seeded.add(widget.initialMessage);
    }
    return seeded;
  }

  List<Map<String, dynamic>> _readMapList(Object? value) {
    if (value is List) {
      return value
          .whereType<Object>()
          .map(
            (Object item) => item is Map<String, dynamic>
                ? item
                : item is Map
                ? Map<String, dynamic>.from(item)
                : const <String, dynamic>{},
          )
          .where((Map<String, dynamic> item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const <Map<String, dynamic>>[];
  }

  bool? _readBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final String normalized = (value?.toString() ?? '').trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'online') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'offline') {
      return false;
    }
    return null;
  }

  DateTime? _readDateTime(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  List<String> _readStringList(Object? value) {
    if (value is List) {
      return value
          .map((Object? item) => item?.toString().trim() ?? '')
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }

  Future<void> _showAttachmentSheet(BuildContext context) {
    final List<({IconData icon, String label})> items =
        <({IconData icon, String label})>[
          (icon: Icons.photo_library_outlined, label: 'Gallery'),
          (icon: Icons.description_outlined, label: 'Document'),
          (icon: Icons.camera_alt_outlined, label: 'Camera'),
          (icon: Icons.location_on_outlined, label: 'Location'),
          (icon: Icons.person_outline_rounded, label: 'Contact'),
          (icon: Icons.headphones_outlined, label: 'Audio'),
        ];

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: items.map((({IconData icon, String label}) item) {
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).pop();
                    unawaited(_handleAttachmentSelection(item.label));
                  },
                  child: Container(
                    width: 96,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, color: AppColors.hexFF26C6DA),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAttachmentSelection(String label) async {
    switch (label.toLowerCase()) {
      case 'gallery':
        await _pickGalleryAttachment();
        return;
      case 'camera':
        await _pickCameraAttachment();
        return;
      case 'document':
        await _pickDocumentAttachment();
        return;
      case 'audio':
        await _pickAudioAttachment();
        return;
      case 'location':
        final String? location = await _promptForLocation();
        if (location == null) {
          return;
        }
        await _sendMessageToBackend(text: location, kind: 'location');
        return;
      case 'contact':
        final String? contact = await _promptForContact();
        if (contact == null) {
          return;
        }
        await _sendMessageToBackend(text: contact, kind: 'contact');
        return;
    }
  }

  Future<void> _pickGalleryAttachment() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) {
      return;
    }
    _setPendingAttachment(
      path: file.path,
      kind: 'gallery',
      label: _fileName(file.path),
    );
  }

  Future<void> _pickCameraAttachment() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) {
      return;
    }
    _setPendingAttachment(
      path: file.path,
      kind: 'camera',
      label: _fileName(file.path),
    );
  }

  Future<void> _pickDocumentAttachment() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>[
        'pdf',
        'doc',
        'docx',
        'txt',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
      ],
    );
    final PlatformFile? file = result?.files.single;
    if (file?.path == null) {
      return;
    }
    _setPendingAttachment(
      path: file!.path!,
      kind: 'document',
      label: file.name,
    );
  }

  Future<void> _pickAudioAttachment() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    final PlatformFile? file = result?.files.single;
    if (file?.path == null) {
      return;
    }
    _setPendingAttachment(path: file!.path!, kind: 'audio', label: file.name);
  }

  Future<String?> _promptForLocation() async {
    final String currentLocation = _currentUser?.location.trim() ?? '';
    final TextEditingController controller = TextEditingController(
      text: currentLocation.isNotEmpty ? currentLocation : 'Dhaka, Bangladesh',
    );
    final String? location = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Share location'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter a location',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              Navigator.of(dialogContext).pop(controller.text.trim());
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    final String normalized = (location ?? '').trim();
    if (normalized.isEmpty) {
      return null;
    }
    return 'Shared location: $normalized';
  }

  Future<String?> _promptForContact() async {
    final UserModel? currentUser = _currentUser;
    final String currentProfileUrl = currentUser?.publicProfileUrl.trim() ?? '';
    final String currentUsername = currentUser?.username.trim() ?? '';
    final String initialDetails = currentProfileUrl.isNotEmpty
        ? currentProfileUrl
        : '@${(currentUsername.isNotEmpty ? currentUsername : widget.user.username).trim()}';
    final TextEditingController nameController = TextEditingController(
      text: (currentUser?.name.trim() ?? '').isNotEmpty
          ? currentUser!.name.trim()
          : widget.user.name,
    );
    final TextEditingController detailsController = TextEditingController(
      text: initialDetails,
    );
    final String? contact = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Share contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsController,
                decoration: const InputDecoration(
                  labelText: 'Phone, username, or profile link',
                  border: OutlineInputBorder(),
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final String details = detailsController.text.trim();
                if (name.isEmpty && details.isEmpty) {
                  Navigator.of(dialogContext).pop();
                  return;
                }
                final StringBuffer buffer = StringBuffer('Shared contact');
                if (name.isNotEmpty) {
                  buffer
                    ..write(': ')
                    ..write(name);
                }
                if (details.isNotEmpty) {
                  buffer
                    ..write('\n')
                    ..write(details);
                }
                Navigator.of(dialogContext).pop(buffer.toString());
              },
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
    nameController.dispose();
    detailsController.dispose();
    final String normalized = (contact ?? '').trim();
    return normalized.isEmpty ? null : normalized;
  }

  Future<_UploadedChatAttachment> _uploadChatAttachment({
    required String localPath,
    required String kind,
  }) async {
    if (localPath.startsWith('http://') || localPath.startsWith('https://')) {
      return _UploadedChatAttachment(
        remotePath: localPath,
        name: _fileName(localPath),
        mimeType: _inferMimeType(localPath, kind),
      );
    }

    final String taskId =
        'chat-${DateTime.now().microsecondsSinceEpoch}-${kind.toLowerCase()}';
    UploadProgress? lastProgress;
    await for (final UploadProgress progress in _uploadService.uploadFile(
      taskId: taskId,
      localPath: localPath,
      fields: <String, String>{
        'resourceType': _uploadResourceType(kind, localPath),
        'folder': 'optizenqor/chat/${widget.initialMessage.chatId}',
        'publicId': taskId,
      },
    )) {
      lastProgress = progress;
    }

    if (lastProgress == null ||
        lastProgress.status != UploadStatus.completed ||
        lastProgress.remotePath == null ||
        lastProgress.remotePath!.trim().isEmpty) {
      throw Exception(lastProgress?.error ?? 'Attachment upload failed.');
    }

    final String remotePath = lastProgress.remotePath!.trim();
    return _UploadedChatAttachment(
      remotePath: remotePath,
      name: _fileName(localPath),
      mimeType: _inferMimeType(localPath, kind),
    );
  }

  Future<void> _handleAttachmentTap(MessageModel message) async {
    final String? path = message.mediaPath;
    if (path == null || path.isEmpty) {
      return;
    }

    if (_isImageMessage(message)) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveViewer(child: _buildImagePreview(path)),
            ),
          );
        },
      );
      return;
    }

    if (message.kind == 'audio' || message.kind == 'voice') {
      await _playAudioFile(message.id, path);
    }
  }

  void _setPendingAttachment({
    required String path,
    required String kind,
    required String label,
  }) {
    FocusScope.of(context).unfocus();
    setState(() {
      _pendingAttachmentPath = path;
      _pendingAttachmentKind = kind;
      _pendingAttachmentLabel = label;
    });
  }

  void _clearPendingAttachment() {
    if (!mounted) {
      return;
    }
    setState(() {
      _pendingAttachmentPath = null;
      _pendingAttachmentKind = null;
      _pendingAttachmentLabel = null;
    });
  }

  String _formatRecordDuration(Duration duration) {
    final String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Duration _parseVoiceDuration(String text) {
    final List<String> parts = text.split(':');
    if (parts.length != 2) {
      return const Duration(seconds: 8);
    }
    final int minutes = int.tryParse(parts[0]) ?? 0;
    final int seconds = int.tryParse(parts[1]) ?? 0;
    return Duration(minutes: minutes, seconds: seconds);
  }

  Duration _voiceDurationForMessage(MessageModel message) {
    if (_playingMessageId == message.id && _playbackDuration > Duration.zero) {
      return _playbackDuration;
    }
    if (message.kind == 'voice') {
      return _parseVoiceDuration(message.text);
    }
    return const Duration(seconds: 1);
  }

  Future<void> _toggleVoicePlayback(MessageModel message) async {
    final String? path = message.mediaPath;
    if (path == null || path.isEmpty) {
      return;
    }

    if (_playingMessageId == message.id && _audioPlayer.playing) {
      await _audioPlayer.pause();
      if (!mounted) {
        return;
      }
      setState(() {
        _playingMessageId = null;
      });
      return;
    }

    await _playAudioFile(message.id, path);
  }

  Future<void> _playAudioFile(String messageId, String path) async {
    try {
      await _audioPlayer.stop();
      final Duration? duration =
          path.startsWith('http://') || path.startsWith('https://')
          ? await _audioPlayer.setUrl(path)
          : await _audioPlayer.setFilePath(path);
      if (!mounted) {
        return;
      }
      setState(() {
        _playingMessageId = messageId;
        _playbackProgress = Duration.zero;
        _playbackDuration = duration ?? Duration.zero;
      });
      await _audioPlayer.play();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to play this audio file.')),
      );
    }
  }

  String _messagePreviewText(MessageModel message) {
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
            : 'Message';
    }
  }

  String _chatErrorMessage(String raw) {
    final String normalized = raw.trim();
    if (normalized.isEmpty) {
      return 'Unable to send message.';
    }
    final String cleaned = normalized.replaceFirst('Exception: ', '');
    return cleaned.length > 120 ? 'Unable to send message.' : cleaned;
  }

  void _closeSearch() {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchController.clear();
      _isSearchOpen = false;
    });
  }

  String? get _headerStatusText {
    if (_otherUserTyping) {
      return 'Typing...';
    }
    if (_chatUser.isOnline == true) {
      return 'Online';
    }
    final DateTime? lastSeen = _chatUser.lastSeen;
    if (lastSeen == null) {
      return null;
    }
    final Duration difference = DateTime.now().difference(lastSeen);
    if (difference.inMinutes < 1) {
      return 'Last seen just now';
    }
    if (difference.inHours < 1) {
      return 'Last seen ${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return 'Last seen ${difference.inHours}h ago';
    }
    return 'Last seen ${difference.inDays}d ago';
  }

  IconData _attachmentIcon(String kind) {
    switch (kind) {
      case 'gallery':
      case 'image':
      case 'photo':
        return Icons.photo_library_outlined;
      case 'camera':
        return Icons.camera_alt_outlined;
      case 'document':
      case 'file':
        return Icons.description_outlined;
      case 'location':
        return Icons.location_on_outlined;
      case 'contact':
        return Icons.person_outline_rounded;
      case 'audio':
        return Icons.headphones_outlined;
      default:
        return Icons.attach_file_rounded;
    }
  }

  bool _isImageMessage(MessageModel message) {
    return message.kind == 'gallery' ||
        message.kind == 'camera' ||
        message.kind == 'image' ||
        message.kind == 'photo' ||
        _isImagePath(message.mediaPath);
  }

  bool _isImagePath(String? path) {
    final String normalized = (path ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return normalized.endsWith('.png') ||
        normalized.endsWith('.jpg') ||
        normalized.endsWith('.jpeg') ||
        normalized.endsWith('.webp') ||
        normalized.endsWith('.gif');
  }

  bool _isVideoPath(String? path) {
    final String normalized = (path ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return normalized.endsWith('.mp4') ||
        normalized.endsWith('.mov') ||
        normalized.endsWith('.m4v') ||
        normalized.endsWith('.webm');
  }

  String _buildVoiceFilePath() {
    final String separator = Platform.pathSeparator;
    return '${Directory.systemTemp.path}${separator}voice_${DateTime.now().microsecondsSinceEpoch}.m4a';
  }

  String _uploadResourceType(String kind, String path) {
    final String normalizedKind = kind.trim().toLowerCase();
    if (normalizedKind == 'gallery' ||
        normalizedKind == 'camera' ||
        normalizedKind == 'image' ||
        normalizedKind == 'photo') {
      return 'image';
    }
    if (normalizedKind == 'audio' || normalizedKind == 'voice') {
      return 'auto';
    }
    if (normalizedKind == 'video' || _isVideoPath(path)) {
      return 'video';
    }
    if (normalizedKind == 'document' || normalizedKind == 'file') {
      return 'raw';
    }
    return 'auto';
  }

  String? _inferMimeType(String path, String kind) {
    final String normalizedKind = kind.trim().toLowerCase();
    final String lowerPath = path.trim().toLowerCase();
    if (normalizedKind == 'gallery' ||
        normalizedKind == 'camera' ||
        normalizedKind == 'image' ||
        normalizedKind == 'photo') {
      if (lowerPath.endsWith('.png')) {
        return 'image/png';
      }
      if (lowerPath.endsWith('.webp')) {
        return 'image/webp';
      }
      return 'image/jpeg';
    }
    if (normalizedKind == 'audio' || normalizedKind == 'voice') {
      if (lowerPath.endsWith('.mp3')) {
        return 'audio/mpeg';
      }
      if (lowerPath.endsWith('.wav')) {
        return 'audio/wav';
      }
      return 'audio/mp4';
    }
    if (normalizedKind == 'video' || _isVideoPath(path)) {
      return 'video/mp4';
    }
    if (lowerPath.endsWith('.pdf')) {
      return 'application/pdf';
    }
    if (lowerPath.endsWith('.doc')) {
      return 'application/msword';
    }
    if (lowerPath.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lowerPath.endsWith('.txt')) {
      return 'text/plain';
    }
    if (lowerPath.endsWith('.xls')) {
      return 'application/vnd.ms-excel';
    }
    if (lowerPath.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    if (lowerPath.endsWith('.ppt')) {
      return 'application/vnd.ms-powerpoint';
    }
    if (lowerPath.endsWith('.pptx')) {
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    }
    return null;
  }

  double _mapAmplitudeToHeight(double amplitude) {
    final double safeAmplitude = amplitude.isFinite ? amplitude : -60;
    final double normalized = ((safeAmplitude + 60) / 60).clamp(0.0, 1.0);
    return 6 + (normalized * 16);
  }

  String _fileName(String path) {
    final String normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }
}

class _UploadedChatAttachment {
  const _UploadedChatAttachment({
    required this.remotePath,
    required this.name,
    this.mimeType,
  });

  final String remotePath;
  final String name;
  final String? mimeType;
}
