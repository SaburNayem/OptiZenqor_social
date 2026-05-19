// ignore_for_file: invalid_use_of_protected_member

part of 'chat_detail_screen.dart';

extension _ChatDetailAttachments on _ChatDetailScreenState {
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
        final String? location = await _buildCurrentLocationMessage();
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

  Future<String?> _buildCurrentLocationMessage() async {
    final _ChatLatLng? currentPosition = await _readCurrentLatLng();
    if (currentPosition != null) {
      return _formatLocationMessage(currentPosition);
    }
    if (!mounted) {
      return null;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to read GPS. Enter latitude and longitude.'),
      ),
    );
    final _ChatLatLng? manualPosition = await _promptForLatLng();
    return manualPosition == null
        ? null
        : _formatLocationMessage(manualPosition);
  }

  Future<_ChatLatLng?> _promptForLatLng() async {
    final TextEditingController controller = TextEditingController(
      text: _extractProfileLatLng(_currentUser?.location)?.formatted ?? '',
    );
    final String? location = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Share location'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '23.810331, 90.412521',
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
    final _ChatLatLng? coordinates = _extractLatLng(normalized);
    if (coordinates != null) {
      return coordinates;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter latitude and longitude.')),
      );
    }
    return null;
  }

  Future<_ChatLatLng?> _readCurrentLatLng() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return _ChatLatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  String _formatLocationMessage(_ChatLatLng location) {
    return 'Shared location: ${location.formatted}\n'
        '${_buildGoogleMapsSearchUrl(location)}';
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
    if (_isImageMessage(message)) {
      if (path == null || path.isEmpty) {
        return;
      }
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

    final _ChatLatLng? sharedLocation = _extractMessageLatLng(message);
    if (sharedLocation != null) {
      await _openSharedLocation(sharedLocation);
      return;
    }

    final String? locationUrl = _extractLocationUrl(message);
    if (locationUrl != null) {
      await _openExternalUrl(locationUrl);
      return;
    }

    if (path == null || path.isEmpty) {
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
      return Duration.zero;
    }
    final int minutes = int.tryParse(parts[0]) ?? 0;
    final int seconds = int.tryParse(parts[1]) ?? 0;
    return Duration(minutes: minutes, seconds: seconds);
  }

  Duration _voiceDurationForMessage(MessageModel message) {
    if (_playingMessageId == message.id && _playbackDuration > Duration.zero) {
      return _playbackDuration;
    }
    final Duration parsed = _parseVoiceDuration(message.text);
    if (parsed > Duration.zero) {
      return parsed;
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
      setState(() {});
      return;
    }

    if (_playingMessageId == message.id &&
        _audioPlayer.processingState != ProcessingState.idle) {
      if (!mounted) {
        return;
      }
      setState(() {
        _playingMessageId = message.id;
      });
      await _audioPlayer.play();
      return;
    }

    await _playAudioFile(message.id, path);
  }

  Future<void> _playAudioFile(
    String messageId,
    String path, {
    Duration? startAt,
    double? startFraction,
  }) async {
    try {
      await _audioPlayer.stop();
      final String normalizedPath = path.trim();
      final Duration? duration = _shouldUseUrlMedia(normalizedPath)
          ? await _audioPlayer.setUrl(normalizedPath)
          : await _audioPlayer.setFilePath(normalizedPath);
      final Duration resolvedDuration = duration ?? Duration.zero;
      Duration seekPosition = startAt ?? Duration.zero;
      if (startFraction != null && resolvedDuration > Duration.zero) {
        seekPosition = Duration(
          milliseconds: (resolvedDuration.inMilliseconds * startFraction)
              .round(),
        );
      }
      if (resolvedDuration > Duration.zero && seekPosition > resolvedDuration) {
        seekPosition = resolvedDuration;
      }
      if (seekPosition > Duration.zero) {
        await _audioPlayer.seek(seekPosition);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _playingMessageId = messageId;
        _playbackProgress = seekPosition;
        _playbackDuration = resolvedDuration;
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

  Future<void> _seekVoicePlayback(MessageModel message, double fraction) async {
    final String? path = message.mediaPath;
    if (path == null || path.isEmpty) {
      return;
    }

    final double clampedFraction = fraction.clamp(0.0, 1.0).toDouble();
    final Duration total = _voiceDurationForMessage(message);
    final Duration target = total > Duration.zero
        ? Duration(
            milliseconds: (total.inMilliseconds * clampedFraction).round(),
          )
        : Duration.zero;

    if (_playingMessageId == message.id &&
        _audioPlayer.processingState != ProcessingState.idle) {
      await _audioPlayer.seek(target);
      if (!mounted) {
        return;
      }
      setState(() {
        _playingMessageId = message.id;
        _playbackProgress = target;
      });
      if (!_audioPlayer.playing) {
        await _audioPlayer.play();
      }
      return;
    }

    await _playAudioFile(
      message.id,
      path,
      startAt: target,
      startFraction: clampedFraction,
    );
  }
}
