part of 'chat_detail_screen.dart';

extension _ChatDetailMessageWidgets on _ChatDetailScreenState {
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
          if (_replyingToMessage != null ||
              _editingMessage != null) ...<Widget>[
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
                ? _buildImagePreview(path, width: 56, height: 56)
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
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
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
        child: const Icon(Icons.reply_rounded, color: AppColors.hexFF26C6DA),
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
      case 'audio':
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
      case 'contact':
        return _buildAttachmentBubble(message, isMe, decoration);
      case 'location':
        return _buildLocationBubble(message, isMe, decoration);
      default:
        if (_isLocationMessage(message)) {
          return _buildLocationBubble(message, isMe, decoration);
        }
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
              if (_buildReplySnippet(message, isMe)
                  case final Widget replySnippet)
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
    return source
        .where((MessageModel message) {
          return _messagePreviewText(message).toLowerCase().contains(query);
        })
        .toList(growable: false);
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
            if (_buildReplySnippet(message, isMe)
                case final Widget replySnippet)
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

  Widget _buildLocationBubble(
    MessageModel message,
    bool isMe,
    BoxDecoration decoration,
  ) {
    final _ChatLatLng? location = _extractMessageLatLng(message);
    final String title = _locationTitle(message);
    final String subtitle = location?.formatted ?? 'Open in Google Maps';

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
            if (_buildReplySnippet(message, isMe)
                case final Widget replySnippet)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: replySnippet,
              ),
            SizedBox(
              width: 260,
              height: 136,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned.fill(child: _buildLocationPreviewMap(isMe)),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.hexFF26C6DA,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.map_outlined,
                    color: isMe ? AppColors.white : AppColors.hexFF26C6DA,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isMe ? AppColors.white : AppColors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isMe
                                ? AppColors.white.withValues(alpha: 0.82)
                                : AppColors.grey600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.open_in_new_rounded,
                    color: isMe
                        ? AppColors.white.withValues(alpha: 0.9)
                        : AppColors.grey500,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPreviewMap(bool isMe) {
    final Color waterColor = isMe
        ? AppColors.white.withValues(alpha: 0.3)
        : const Color(0xFFD9F2F6);
    final Color landColor = isMe
        ? AppColors.white.withValues(alpha: 0.18)
        : const Color(0xFFEAF7E9);
    final Color roadColor = isMe
        ? AppColors.white.withValues(alpha: 0.58)
        : AppColors.white;
    final Color routeColor = isMe
        ? AppColors.white.withValues(alpha: 0.82)
        : AppColors.hexFF26C6DA;

    return DecoratedBox(
      decoration: BoxDecoration(color: landColor),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: -28,
            top: -18,
            child: Container(
              width: 150,
              height: 92,
              decoration: BoxDecoration(
                color: waterColor,
                borderRadius: BorderRadius.circular(46),
              ),
            ),
          ),
          Positioned(
            right: -18,
            bottom: -20,
            child: Container(
              width: 142,
              height: 88,
              decoration: BoxDecoration(
                color: waterColor.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(44),
              ),
            ),
          ),
          Positioned(
            left: -10,
            right: -10,
            top: 38,
            child: Transform.rotate(
              angle: -0.22,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: roadColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          Positioned(
            left: 34,
            right: -24,
            bottom: 42,
            child: Transform.rotate(
              angle: 0.42,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: roadColor.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          Positioned(
            left: 74,
            right: 22,
            top: 78,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: routeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
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
            if (_buildReplySnippet(message, isMe)
                case final Widget replySnippet)
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

  Widget _buildImagePreview(
    String path, {
    double width = 220,
    double height = 180,
  }) {
    final String normalizedPath = path.trim();
    final bool localFile = _hasLocalFile(normalizedPath);
    if (localFile) {
      return Image.file(
        File(normalizedPath),
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      normalizedPath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
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
          width: width,
          height: height,
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
    final bool isActive = _playingMessageId == message.id;
    final bool isPlaying = isActive && _audioPlayer.playing;
    final Duration total = _voiceDurationForMessage(message);
    final Duration current = isActive ? _playbackProgress : Duration.zero;
    final double progress = total.inMilliseconds == 0
        ? 0
        : current.inMilliseconds / total.inMilliseconds;
    final double clampedProgress = progress.clamp(0.0, 1.0).toDouble();
    final String? voicePath = message.mediaPath?.trim();
    final bool hasVoiceFile = _canOpenMediaPath(voicePath);

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
                onTap: hasVoiceFile
                    ? () => _toggleVoicePlayback(message)
                    : null,
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
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: hasVoiceFile
                          ? (TapDownDetails details) {
                              final double width = constraints.maxWidth <= 0
                                  ? 1
                                  : constraints.maxWidth;
                              final double fraction =
                                  (details.localPosition.dx / width)
                                      .clamp(0.0, 1.0)
                                      .toDouble();
                              unawaited(_seekVoicePlayback(message, fraction));
                            }
                          : null,
                      child: Row(
                        children: List<Widget>.generate(
                          _ChatDetailScreenState._voiceWaveHeights.length,
                          (int index) {
                            final bool active =
                                ((index + 1) /
                                        _ChatDetailScreenState
                                            ._voiceWaveHeights
                                            .length) <=
                                    clampedProgress &&
                                isActive;
                            return Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                width: 3,
                                height: _ChatDetailScreenState
                                    ._voiceWaveHeights[index],
                                decoration: BoxDecoration(
                                  color: active
                                      ? (isMe
                                            ? AppColors.white
                                            : AppColors.hexFF26C6DA)
                                      : (isMe
                                            ? AppColors.white.withValues(
                                                alpha: 0.45,
                                              )
                                            : AppColors.grey400),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _formatRecordDuration(isActive ? current : total),
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
}
