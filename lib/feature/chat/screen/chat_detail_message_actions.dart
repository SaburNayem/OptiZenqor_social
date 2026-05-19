// ignore_for_file: invalid_use_of_protected_member

part of 'chat_detail_screen.dart';

extension _ChatDetailMessageActions on _ChatDetailScreenState {
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
        final List<({String value, IconData icon, String label})>
        actions = <({String value, IconData icon, String label})>[
          (value: 'reply', icon: Icons.reply_rounded, label: 'Reply'),
          (
            value: 'pin',
            icon: message.starred ? Icons.push_pin : Icons.push_pin_outlined,
            label: message.starred ? 'Unpin' : 'Pin',
          ),
          (value: 'forward', icon: Icons.forward_rounded, label: 'Forward'),
          if (isMe) (value: 'edit', icon: Icons.edit_outlined, label: 'Edit'),
          if (isMe)
            (value: 'delete', icon: Icons.delete_outline, label: 'Delete'),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: actions.map((
                ({String value, IconData icon, String label}) action,
              ) {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to edit message.')));
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
              content: const Text(
                'This message will be removed from the chat.',
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
      if (_editingMessage?.id == message.id ||
          _replyingToMessage?.id == message.id) {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to pin message.')));
    }
  }

  Future<void> _forwardMessageToThread(MessageModel message) async {
    try {
      final List<ChatThreadModel> threads = await _chatRepository
          .fetchThreads();
      if (!mounted) {
        return;
      }
      final ChatThreadModel?
      target = await showModalBottomSheet<ChatThreadModel>(
        context: context,
        showDragHandle: true,
        builder: (BuildContext context) {
          final List<ChatThreadModel> available = threads
              .where(
                (ChatThreadModel item) =>
                    item.chatId != widget.initialMessage.chatId,
              )
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
}
