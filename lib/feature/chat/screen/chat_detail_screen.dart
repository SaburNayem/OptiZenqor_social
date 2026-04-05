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
    8, 11, 14, 10, 16, 18, 12, 9, 15, 19, 13, 8, 16, 14, 10, 18, 12, 9, 15, 11,
  ];
  static const List<double> _recordWaveHeights = <double>[
    8, 12, 16, 10, 14, 18, 9, 13, 17, 11, 15, 19, 10, 14, 16, 12, 9, 13,
  ];

  late final ValueNotifier<List<MessageModel>> _messages;
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Timer? _recordTimer;

  bool _isTyping = false;
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  String? _recordingPath;
  String? _playingMessageId;
  Duration _playbackProgress = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  List<double> _activeRecordWaveHeights = List<double>.filled(18, 8);

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    _messages = ValueNotifier<List<MessageModel>>(
      <MessageModel>[
        MessageModel(
          id: 'm1',
          chatId: widget.initialMessage.chatId,
          senderId: widget.user.id,
          text: 'Hey Alex! How are you doing?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          read: true,
        ),
        MessageModel(
          id: 'm2',
          chatId: widget.initialMessage.chatId,
          senderId: 'me',
          text:
              'Hey Sarah! I am doing great, just working on a new project. How about you?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          read: true,
        ),
        MessageModel(
          id: 'm3',
          chatId: widget.initialMessage.chatId,
          senderId: widget.user.id,
          text: 'Same here. Been super busy this week.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
          read: true,
        ),
        MessageModel(
          id: 'm4',
          chatId: widget.initialMessage.chatId,
          senderId: widget.user.id,
          text: 'Are we still on for tomorrow?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          read: true,
        ),
      ],
    );
    _messageController.addListener(_handleMessageChanged);
    _positionSubscription = _audioPlayer.positionStream.listen((Duration value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _playbackProgress = value;
      });
    });
    _durationSubscription = _audioPlayer.durationStream.listen((Duration? value) {
      if (!mounted || value == null) {
        return;
      }
      setState(() {
        _playbackDuration = value;
      });
    });
    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      (PlayerState state) {
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
      },
    );
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _amplitudeSubscription?.cancel();
    _messageController
      ..removeListener(_handleMessageChanged)
      ..dispose();
    _messages.dispose();
    unawaited(_audioPlayer.dispose());
    unawaited(_audioRecorder.dispose());
    super.dispose();
  }

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
                  backgroundImage: NetworkImage(widget.user.avatar),
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
                  widget.user.name,
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
              builder: (BuildContext context, List<MessageModel> messages, _) {
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length + 1,
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

                    final MessageModel message = messages[index - 1];
                    final bool isMe = message.senderId == 'me';
                    final bool showAvatar = !isMe &&
                        (index == 1 || messages[index - 2].senderId == 'me');

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
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe)
                                SizedBox(
                                  width: 40,
                                  child: showAvatar
                                      ? CircleAvatar(
                                          radius: 16,
                                          backgroundImage: NetworkImage(
                                            widget.user.avatar,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              if (!isMe) const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                child: _buildMessageBubble(message, isMe),
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
    final bool showSend = _isTyping || _isRecording;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => _showAttachmentSheet(context),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.grey,
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
              onPressed: _sendCurrentPayload,
              icon: const Icon(Icons.send_rounded, color: Color(0xFF26C6DA)),
            )
          else
            IconButton(
              onPressed: _toggleVoiceRecording,
              icon: const Icon(Icons.mic_none_rounded, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildTextComposerField() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: TextField(
        controller: _messageController,
        decoration: const InputDecoration(
          hintText: 'Type a message...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final BoxDecoration decoration = BoxDecoration(
      color: isMe ? const Color(0xFF26C6DA) : Colors.grey.shade50,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomLeft: Radius.circular(isMe ? 20 : 4),
        bottomRight: Radius.circular(isMe ? 4 : 20),
      ),
      border: isMe ? null : Border.all(color: Colors.grey.shade100),
    );

    switch (message.kind) {
      case 'voice':
        return _buildVoiceBubble(message, isMe, decoration);
      case 'gallery':
      case 'document':
      case 'camera':
      case 'location':
      case 'contact':
      case 'audio':
        return _buildAttachmentBubble(message, isMe, decoration);
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: decoration,
          child: Text(
            message.text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        );
    }
  }

  Widget _buildAttachmentBubble(
    MessageModel message,
    bool isMe,
    BoxDecoration decoration,
  ) {
    final Map<String, IconData> icons = <String, IconData>{
      'gallery': Icons.photo_library_outlined,
      'document': Icons.description_outlined,
      'camera': Icons.camera_alt_outlined,
      'location': Icons.location_on_outlined,
      'contact': Icons.person_outline_rounded,
      'audio': Icons.headphones_outlined,
    };

    return InkWell(
      onTap: () => _handleAttachmentTap(message),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: decoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icons[message.kind] ?? Icons.attach_file_rounded,
              color: isMe ? Colors.white : const Color(0xFF26C6DA),
              size: 20,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
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
      child: Row(
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
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFF26C6DA).withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: hasVoiceFile
                    ? (isMe ? Colors.white : const Color(0xFF26C6DA))
                    : Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: List<Widget>.generate(_voiceWaveHeights.length,
                  (int index) {
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
                          ? (isMe ? Colors.white : const Color(0xFF26C6DA))
                          : (isMe
                              ? Colors.white.withValues(alpha: 0.45)
                              : Colors.grey.shade400),
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
              color: isMe ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _stopRecording(resetOnly: true),
            child: const Icon(
              Icons.stop_circle_outlined,
              color: Color(0xFF26C6DA),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: List<Widget>.generate(_activeRecordWaveHeights.length,
                  (int index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Container(
                    width: 3,
                    height: _activeRecordWaveHeights[index],
                    decoration: BoxDecoration(
                      color: const Color(0xFF26C6DA),
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
              color: Colors.black87,
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
      final double mappedHeight =
          _mapAmplitudeToHeight(amplitude.current);
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
    if (_isRecording) {
      final String durationText = _formatRecordDuration(_recordDuration);
      final String? voicePath = await _finishVoiceRecordingForSend();
      if (voicePath == null) {
        return;
      }
      _appendLocalMessage(
        durationText,
        kind: 'voice',
        mediaPath: voicePath,
      );
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) {
          return;
        }
        _appendRemoteMessage(
          durationText,
          kind: 'voice',
          mediaPath: voicePath,
        );
      });
      return;
    }

    final String text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    _appendLocalMessage(text);
    _messageController.clear();
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

  void _appendLocalMessage(
    String text, {
    String kind = 'text',
    String? mediaPath,
  }) {
    _messages.value = <MessageModel>[
      ..._messages.value,
      MessageModel(
        id: 'm_${DateTime.now().microsecondsSinceEpoch}',
        chatId: widget.initialMessage.chatId,
        senderId: 'me',
        text: text,
        timestamp: DateTime.now(),
        read: true,
        kind: kind,
        mediaPath: mediaPath,
      ),
    ];
  }

  void _appendRemoteMessage(
    String text, {
    String kind = 'text',
    String? mediaPath,
  }) {
    _messages.value = <MessageModel>[
      ..._messages.value,
      MessageModel(
        id: 'm_${DateTime.now().microsecondsSinceEpoch}_remote',
        chatId: widget.initialMessage.chatId,
        senderId: widget.user.id,
        text: text,
        timestamp: DateTime.now().add(const Duration(seconds: 1)),
        read: true,
        kind: kind,
        mediaPath: mediaPath,
      ),
    ];
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
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, color: const Color(0xFF26C6DA)),
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
        _appendLocalMessage('Current location shared', kind: 'location');
        Future<void>.delayed(const Duration(milliseconds: 450), () {
          if (!mounted) {
            return;
          }
          _appendRemoteMessage('Location received', kind: 'location');
        });
        return;
      case 'contact':
        _appendLocalMessage('Contact card shared', kind: 'contact');
        Future<void>.delayed(const Duration(milliseconds: 450), () {
          if (!mounted) {
            return;
          }
          _appendRemoteMessage('Contact received', kind: 'contact');
        });
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
    _appendLocalMessage(
      _fileName(file.path),
      kind: 'gallery',
      mediaPath: file.path,
    );
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }
      _appendRemoteMessage(
        'Received ${_fileName(file.path)}',
        kind: 'gallery',
        mediaPath: file.path,
      );
    });
  }

  Future<void> _pickCameraAttachment() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) {
      return;
    }
    _appendLocalMessage(
      _fileName(file.path),
      kind: 'camera',
      mediaPath: file.path,
    );
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }
      _appendRemoteMessage(
        'Received ${_fileName(file.path)}',
        kind: 'camera',
        mediaPath: file.path,
      );
    });
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
    _appendLocalMessage(file!.name, kind: 'document', mediaPath: file.path);
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }
      _appendRemoteMessage(
        'Received ${file.name}',
        kind: 'document',
        mediaPath: file.path,
      );
    });
  }

  Future<void> _pickAudioAttachment() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    final PlatformFile? file = result?.files.single;
    if (file?.path == null) {
      return;
    }
    _appendLocalMessage(file!.name, kind: 'audio', mediaPath: file.path);
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }
      _appendRemoteMessage(
        'Received ${file.name}',
        kind: 'audio',
        mediaPath: file.path,
      );
    });
  }

  Future<void> _handleAttachmentTap(MessageModel message) async {
    final String? path = message.mediaPath;
    if (path == null || path.isEmpty) {
      return;
    }

    if (message.kind == 'audio' || message.kind == 'voice') {
      await _playAudioFile(message.id, path);
    }
  }

  String _formatRecordDuration(Duration duration) {
    final String minutes = duration.inMinutes.remainder(60).toString().padLeft(
          2,
          '0',
        );
    final String seconds = duration.inSeconds.remainder(60).toString().padLeft(
          2,
          '0',
        );
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
    final File file = File(path);
    if (!file.existsSync()) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio file is not available.')),
      );
      return;
    }

    try {
      await _audioPlayer.stop();
      final Duration? duration = await _audioPlayer.setFilePath(path);
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

  String _buildVoiceFilePath() {
    final String separator = Platform.pathSeparator;
    return '${Directory.systemTemp.path}${separator}voice_${DateTime.now().microsecondsSinceEpoch}.m4a';
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
