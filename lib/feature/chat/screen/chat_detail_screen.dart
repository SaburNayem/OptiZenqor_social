import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

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

part 'chat_detail_message_widgets.dart';
part 'chat_detail_message_sending.dart';
part 'chat_detail_message_actions.dart';
part 'chat_detail_attachments.dart';
part 'chat_detail_message_helpers.dart';

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
      _socketService
          .send(
            'thread.leave',
            data: <String, dynamic>{'threadId': widget.initialMessage.chatId},
          )
          .catchError((_) {}),
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
      _socketService
          .send(
            'thread.join',
            data: <String, dynamic>{'threadId': widget.initialMessage.chatId},
          )
          .catchError((_) {}),
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
                            color:
                                _otherUserTyping || _chatUser.isOnline == true
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
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<String>>[
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
                                        margin: const EdgeInsets.only(
                                          bottom: 24,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.grey100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                              ? visibleMessages[index - 2]
                                                        .senderId ==
                                                    _currentUserId
                                              : visibleMessages[index - 2]
                                                        .senderId ==
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
                                              child:
                                                  _buildInteractiveMessageBubble(
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
                                                  _messageStatusLabel(
                                                        message,
                                                      ) !=
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

class _ChatLatLng {
  const _ChatLatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  String get formatted =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}
