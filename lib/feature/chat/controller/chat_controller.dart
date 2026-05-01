import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/data/models/load_state_model.dart';
import '../../../core/data/models/message_model.dart';
import '../../../core/data/service/analytics_service.dart';
import '../../../core/socket/socket_event.dart';
import '../../../core/socket/socket_handler.dart';
import '../../../core/socket/socket_service.dart';
import '../model/chat_thread_model.dart';
import '../model/chat_inbox_filter_model.dart';
import '../repository/chat_repository.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    ChatRepository? repository,
    AnalyticsService? analytics,
    SocketService? socketService,
  }) : _repository = repository ?? ChatRepository(),
       _analytics = analytics ?? AnalyticsService(),
       _socketService = socketService ?? SocketService.instance;

  final ChatRepository _repository;
  final AnalyticsService _analytics;
  final SocketService _socketService;
  StreamSubscription<SocketEnvelope>? _chatSubscription;

  LoadStateModel state = const LoadStateModel();
  List<ChatThreadModel> threads = <ChatThreadModel>[];
  final Set<String> _pinnedChatIds = <String>{};
  final Set<String> _archivedChatIds = <String>{};
  final Set<String> _retryChatIds = <String>{};
  ChatInboxFilterModel filter = const ChatInboxFilterModel(
    filter: ChatInboxFilter.all,
  );

  bool get isLoading => state.isLoading;
  bool get hasError => state.hasError;
  bool isPinned(String chatId) => _pinnedChatIds.contains(chatId);
  bool isArchived(String chatId) => _archivedChatIds.contains(chatId);
  bool needsRetry(String chatId) => _retryChatIds.contains(chatId);

  void setFilter(ChatInboxFilter next) {
    filter = ChatInboxFilterModel(filter: next);
    notifyListeners();
  }

  List<ChatThreadModel> get inboxThreads {
    final visible = threads
        .where(
          (ChatThreadModel item) => !_archivedChatIds.contains(item.chatId),
        )
        .toList();
    visible.sort((ChatThreadModel a, ChatThreadModel b) {
      final bool aPinned = _pinnedChatIds.contains(a.chatId);
      final bool bPinned = _pinnedChatIds.contains(b.chatId);
      if (aPinned == bPinned) {
        final DateTime aTime = a.lastMessageModel?.timestamp ?? DateTime(1970);
        final DateTime bTime = b.lastMessageModel?.timestamp ?? DateTime(1970);
        return bTime.compareTo(aTime);
      }
      return aPinned ? -1 : 1;
    });
    return visible;
  }

  int unreadCount(String chatId) => threads
      .where((ChatThreadModel item) => item.chatId == chatId)
      .fold<int>(
        0,
        (int total, ChatThreadModel item) => total + item.unreadCount,
      );

  Future<void> loadChats() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();
    try {
      threads = await _repository.fetchThreads();
      await _ensureSocketSubscription();
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        isEmpty: threads.isEmpty,
      );
      notifyListeners();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Unable to load conversations',
      );
      notifyListeners();
    }
  }

  Future<void> _ensureSocketSubscription() async {
    if (_chatSubscription != null) {
      return;
    }
    await _socketService.connect();
    _chatSubscription = _socketService.chatEvents.listen(_handleSocketEvent);
  }

  void _handleSocketEvent(SocketEnvelope envelope) {
    switch (envelope.event) {
      case SocketEvent.chatMessage:
        _applyIncomingMessage(envelope.data);
        return;
      case SocketEvent.chatThreadUpdated:
        _applyThreadUpdate(envelope.data);
        return;
      default:
        return;
    }
  }

  void _applyIncomingMessage(Map<String, dynamic> payload) {
    final MessageModel message = MessageModel.fromApiJson(payload);
    if (message.chatId.isEmpty) {
      return;
    }
    final int index = threads.indexWhere(
      (ChatThreadModel item) => item.chatId == message.chatId,
    );
    if (index == -1) {
      return;
    }
    final ChatThreadModel current = threads[index];
    threads[index] = ChatThreadModel(
      id: current.id,
      chatId: current.chatId,
      title: current.title,
      lastMessage: message.text.isEmpty ? current.lastMessage : message.text,
      user: current.user,
      lastMessageModel: message,
      unreadCount: current.unreadCount + (message.read ? 0 : 1),
    );
    notifyListeners();
  }

  void _applyThreadUpdate(Map<String, dynamic> payload) {
    final ChatThreadModel thread = ChatThreadModel.fromApiJson(
      payload,
      currentUserId: '',
    );
    if (thread.chatId.isEmpty) {
      return;
    }
    final int index = threads.indexWhere(
      (ChatThreadModel item) => item.chatId == thread.chatId,
    );
    if (index == -1) {
      threads = <ChatThreadModel>[thread, ...threads];
    } else {
      threads[index] = thread;
    }
    notifyListeners();
  }

  void togglePinned(String chatId) {
    if (_pinnedChatIds.contains(chatId)) {
      _pinnedChatIds.remove(chatId);
    } else {
      _pinnedChatIds.add(chatId);
    }
    _analytics.logEvent(
      'chat_pin_toggle',
      params: <String, dynamic>{
        'chatId': chatId,
        'pinned': _pinnedChatIds.contains(chatId),
      },
    );
    notifyListeners();
  }

  void toggleArchived(String chatId) {
    if (_archivedChatIds.contains(chatId)) {
      _archivedChatIds.remove(chatId);
    } else {
      _archivedChatIds.add(chatId);
    }
    _analytics.logEvent(
      'chat_archive_toggle',
      params: <String, dynamic>{
        'chatId': chatId,
        'archived': _archivedChatIds.contains(chatId),
      },
    );
    notifyListeners();
  }

  Future<void> simulateSendFailure(String chatId) async {
    _retryChatIds.add(chatId);
    notifyListeners();
  }

  void retry(String chatId) {
    _retryChatIds.remove(chatId);
    notifyListeners();
  }

  void deleteConversation(String chatId) {
    threads = threads.where((message) => message.chatId != chatId).toList();
    _pinnedChatIds.remove(chatId);
    _archivedChatIds.remove(chatId);
    _retryChatIds.remove(chatId);
    notifyListeners();
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _chatSubscription = null;
    super.dispose();
  }
}
