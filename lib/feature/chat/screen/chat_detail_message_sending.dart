// ignore_for_file: invalid_use_of_protected_member

part of 'chat_detail_screen.dart';

extension _ChatDetailMessageSending on _ChatDetailScreenState {
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
      _activeRecordWaveHeights = List<double>.from(
        _ChatDetailScreenState._recordWaveHeights,
      );
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
    double? latitude,
    double? longitude,
    String? locationUrl,
    String? locationName,
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
      latitude: latitude,
      longitude: longitude,
      locationUrl: locationUrl,
      locationName: locationName,
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
    final _ChatLatLng? sharedLocation = normalizedKind == 'location'
        ? _extractLatLng(normalizedText)
        : null;
    final String? sharedLocationUrl = normalizedKind == 'location'
        ? (_extractMapsUrlFromText(normalizedText) ??
              (sharedLocation == null
                  ? null
                  : _buildGoogleMapsSearchUrl(sharedLocation)))
        : null;
    final String? sharedLocationName = normalizedKind == 'location'
        ? _locationNameFromText(normalizedText)
        : null;
    final MessageModel optimistic = _appendLocalMessage(
      optimisticText,
      kind: kind,
      mediaPath: localMediaPath,
      latitude: sharedLocation?.latitude,
      longitude: sharedLocation?.longitude,
      locationUrl: sharedLocationUrl,
      locationName: sharedLocationName,
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
        latitude: sharedLocation?.latitude,
        longitude: sharedLocation?.longitude,
        locationUrl: sharedLocationUrl,
        locationName: sharedLocationName,
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
          latitude: sent.latitude ?? sharedLocation?.latitude,
          longitude: sent.longitude ?? sharedLocation?.longitude,
          locationUrl: (sent.locationUrl ?? '').trim().isNotEmpty
              ? sent.locationUrl
              : sharedLocationUrl,
          locationName: (sent.locationName ?? '').trim().isNotEmpty
              ? sent.locationName
              : sharedLocationName,
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
      ScaffoldMessenger.of(context).showSnackBar(
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
}
