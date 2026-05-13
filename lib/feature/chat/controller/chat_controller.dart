import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/data/models/load_state_model.dart';
import '../../../core/data/models/message_model.dart';
import '../../../core/data/service/analytics_service.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/socket/socket_event.dart';
import '../../../core/socket/socket_handler.dart';
import '../../../core/socket/socket_service.dart';
import '../../auth/repository/auth_repository.dart';
import '../model/chat_thread_model.dart';
import '../model/chat_inbox_filter_model.dart';
import '../repository/chat_repository.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    ChatRepository? repository,
    AnalyticsService? analytics,
    SocketService? socketService,
    AuthRepository? authRepository,
  }) : _repository = repository ?? ChatRepository(),
       _analytics = analytics ?? AnalyticsService(),
       _socketService = socketService ?? SocketService.instance,
       _authRepository = authRepository ?? AuthRepository();

  final ChatRepository _repository;
  final AnalyticsService _analytics;
  final SocketService _socketService;
  final AuthRepository _authRepository;
  StreamSubscription<SocketEnvelope>? _chatSubscription;
  Timer? _refreshTimer;
  bool _isDisposed = false;
  bool _isBackgroundRefreshing = false;
  String _currentUserId = '';

  LoadStateModel state = const LoadStateModel();
  List<ChatThreadModel> threads = <ChatThreadModel>[];
  final Set<String> _pinnedChatIds = <String>{};
  final Set<String> _archivedChatIds = <String>{};
  final Set<String> _mutedChatIds = <String>{};
  final Set<String> _retryChatIds = <String>{};
  final Set<String> _typingThreadIds = <String>{};
  ChatInboxFilterModel filter = const ChatInboxFilterModel(
    filter: ChatInboxFilter.all,
  );

  bool get isLoading => state.isLoading;
  bool get hasError => state.hasError;
  bool isPinned(String chatId) => _pinnedChatIds.contains(chatId);
  bool isArchived(String chatId) => _archivedChatIds.contains(chatId);
  bool isMuted(String chatId) => _mutedChatIds.contains(chatId);
  bool needsRetry(String chatId) => _retryChatIds.contains(chatId);
  bool isThreadTyping(String chatId) => _typingThreadIds.contains(chatId);

  void setFilter(ChatInboxFilter next) {
    filter = ChatInboxFilterModel(filter: next);
    _notifySafely();
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

  int unreadCountForThread(ChatThreadModel thread) {
    final int rawCount = thread.unreadCount < 0 ? 0 : thread.unreadCount;
    final MessageModel? lastMessage = thread.lastMessageModel;
    if (rawCount == 0) {
      return 0;
    }
    if (_currentUserId.isNotEmpty &&
        lastMessage != null &&
        lastMessage.senderId == _currentUserId) {
      return 0;
    }
    return rawCount;
  }

  int unreadCount(String chatId) => threads
      .where((ChatThreadModel item) => item.chatId == chatId)
      .fold<int>(
        0,
        (int total, ChatThreadModel item) => total + unreadCountForThread(item),
      );

  int get totalUnreadCount => threads.fold<int>(
    0,
    (int total, ChatThreadModel item) => total + unreadCountForThread(item),
  );

  bool get hasUnreadMessages => totalUnreadCount > 0;

  Future<void> loadChats() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    _notifySafely();
    try {
      final currentUser = await _authRepository.currentUser();
      _currentUserId = currentUser?.id ?? '';
      final List<ChatThreadModel> nextThreads = await _repository
          .fetchThreads();
      final Map<String, Map<String, dynamic>> preferences = await _repository
          .fetchThreadPreferences()
          .catchError((_) => <String, Map<String, dynamic>>{});
      final Map<String, dynamic> presence = await _repository
          .fetchPresenceSnapshot()
          .catchError((_) => <String, dynamic>{});
      if (_isDisposed) {
        return;
      }
      _applyThreadPreferences(preferences);
      threads = _applyPresence(nextThreads, presence);
      await _ensureSocketSubscription();
      if (_isDisposed) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        isEmpty: threads.isEmpty,
      );
      _notifySafely();
    } catch (_) {
      if (_isDisposed) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Unable to load conversations',
      );
      _notifySafely();
    }
  }

  Future<void> _ensureSocketSubscription() async {
    if (_chatSubscription != null) {
      return;
    }
    await _socketService.connect();
    unawaited(
      _socketService.send(
        'presence.subscribe',
        data: const <String, dynamic>{},
      ).catchError((_) {}),
    );
    _chatSubscription = _socketService.chatEvents.listen(_handleSocketEvent);
    _refreshTimer ??= Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isDisposed) {
        return;
      }
      unawaited(_refreshFromServer());
    });
  }

  Future<void> _refreshFromServer() async {
    if (_isBackgroundRefreshing) {
      return;
    }
    _isBackgroundRefreshing = true;
    try {
      final List<ChatThreadModel> nextThreads = await _repository.fetchThreads();
      final Map<String, dynamic> presence = await _repository
          .fetchPresenceSnapshot()
          .catchError((_) => <String, dynamic>{});
      if (_isDisposed) {
        return;
      }
      threads = _applyPresence(nextThreads, presence);
      _notifySafely();
    } catch (_) {
      return;
    } finally {
      _isBackgroundRefreshing = false;
    }
  }

  void _handleSocketEvent(SocketEnvelope envelope) {
    if (_isDisposed) {
      return;
    }
    switch (envelope.event) {
      case SocketEvent.chatMessage:
        _applyIncomingMessage(envelope.data);
        return;
      case SocketEvent.chatThreadUpdated:
        _applyThreadUpdate(envelope.data);
        return;
      case SocketEvent.chatPresence:
        _applyPresenceEvent(envelope.data);
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
      lastMessage: message.text.isEmpty
          ? _fallbackMessageLabel(message)
          : message.text,
      user: current.user,
      lastMessageModel: message,
      unreadCount:
          message.senderId == _currentUserId || message.read
          ? current.unreadCount
          : current.unreadCount + 1,
    );
    _notifySafely();
  }

  void _applyThreadUpdate(Map<String, dynamic> payload) {
    final ChatThreadModel thread = ChatThreadModel.fromApiJson(
      payload,
      currentUserId: _currentUserId,
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
    _notifySafely();
  }

  Future<void> togglePinned(String chatId) async {
    final bool next = !_pinnedChatIds.contains(chatId);
    _setPinned(chatId, next);
    _analytics.logEvent(
      'chat_pin_toggle',
      params: <String, dynamic>{'chatId': chatId, 'pinned': next},
    );
    try {
      await _repository.updateThreadPreference(
        threadId: chatId,
        action: 'pin',
        value: next,
      );
    } catch (_) {
      _setPinned(chatId, !next);
    }
  }

  Future<void> toggleArchived(String chatId) async {
    final bool next = !_archivedChatIds.contains(chatId);
    _setArchived(chatId, next);
    _analytics.logEvent(
      'chat_archive_toggle',
      params: <String, dynamic>{'chatId': chatId, 'archived': next},
    );
    try {
      await _repository.updateThreadPreference(
        threadId: chatId,
        action: 'archive',
        value: next,
      );
    } catch (_) {
      _setArchived(chatId, !next);
    }
  }

  Future<void> toggleMuted(String chatId) async {
    final bool next = !_mutedChatIds.contains(chatId);
    _setMuted(chatId, next);
    try {
      await _repository.updateThreadPreference(
        threadId: chatId,
        action: 'mute',
        value: next,
      );
    } catch (_) {
      _setMuted(chatId, !next);
    }
  }

  Future<void> markUnread(String chatId, {required bool value}) async {
    try {
      await _repository.updateThreadPreference(
        threadId: chatId,
        action: 'unread',
        value: value,
      );
      threads = threads
          .map((ChatThreadModel item) {
            if (item.chatId != chatId) {
              return item;
            }
            return ChatThreadModel(
              id: item.id,
              chatId: item.chatId,
              title: item.title,
              lastMessage: item.lastMessage,
              user: item.user,
              lastMessageModel: item.lastMessageModel,
              unreadCount: value
                  ? (item.unreadCount == 0 ? 1 : item.unreadCount)
                  : 0,
            );
          })
          .toList(growable: false);
      _notifySafely();
    } catch (_) {
      return;
    }
  }

  Future<void> simulateSendFailure(String chatId) async {
    _retryChatIds.add(chatId);
    _notifySafely();
  }

  void retry(String chatId) {
    _retryChatIds.remove(chatId);
    _notifySafely();
  }

  void deleteConversation(String chatId) {
    threads = threads.where((message) => message.chatId != chatId).toList();
    _pinnedChatIds.remove(chatId);
    _archivedChatIds.remove(chatId);
    _mutedChatIds.remove(chatId);
    _retryChatIds.remove(chatId);
    _notifySafely();
  }

  void _applyThreadPreferences(Map<String, Map<String, dynamic>> preferences) {
    _pinnedChatIds.clear();
    _archivedChatIds.clear();
    _mutedChatIds.clear();
    preferences.forEach((String threadId, Map<String, dynamic> value) {
      if ((value['pinned'] as bool? ?? false) == true) {
        _pinnedChatIds.add(threadId);
      }
      if ((value['archived'] as bool? ?? false) == true) {
        _archivedChatIds.add(threadId);
      }
      if ((value['muted'] as bool? ?? false) == true) {
        _mutedChatIds.add(threadId);
      }
    });
  }

  List<ChatThreadModel> _applyPresence(
    List<ChatThreadModel> source,
    Map<String, dynamic> snapshot,
  ) {
    final List<Map<String, dynamic>> users = _readPresenceUsers(snapshot);
    final Map<String, Set<String>> typingByThread = _readThreadTyping(snapshot);
    _typingThreadIds
      ..clear()
      ..addAll(
        typingByThread.entries
            .where((MapEntry<String, Set<String>> entry) => entry.value.isNotEmpty)
            .map((MapEntry<String, Set<String>> entry) => entry.key),
      );
    if (users.isEmpty) {
      return source;
    }
    final Map<String, Map<String, dynamic>> byUserId =
        <String, Map<String, dynamic>>{
          for (final Map<String, dynamic> item in users)
            (item['userId'] ?? item['id'] ?? '').toString(): item,
        }..remove('');
    return source
        .map((ChatThreadModel thread) {
          final Map<String, dynamic>? presence = byUserId[thread.user.id];
          if (presence == null) {
            return thread;
          }
          return ChatThreadModel(
            id: thread.id,
            chatId: thread.chatId,
            title: thread.title,
            lastMessage: thread.lastMessage,
            user: thread.user.copyWith(
              isOnline: ApiPayloadReader.readBool(
                presence['isOnline'] ?? presence['online'],
              ),
              lastSeen: ApiPayloadReader.readDateTime(presence['lastSeen']),
            ),
            lastMessageModel: thread.lastMessageModel,
            unreadCount: thread.unreadCount,
          );
        })
        .toList(growable: false);
  }

  void _applyPresenceEvent(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>> users = _readPresenceUsers(payload);
    final List<Map<String, dynamic>> threadStates = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['threadStates'],
    );
    if (users.isEmpty && threadStates.isEmpty) {
      return;
    }
    threads = _applyPresence(threads, <String, dynamic>{
      if (users.isNotEmpty) 'users': users,
      if (threadStates.isNotEmpty) 'threadStates': threadStates,
    });
    _notifySafely();
  }

  List<Map<String, dynamic>> _readPresenceUsers(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>> directUsers = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['users'],
    );
    if (directUsers.isNotEmpty) {
      return directUsers;
    }
    final String userId = (payload['userId'] ?? payload['id'] ?? '').toString();
    if (userId.isEmpty) {
      return const <Map<String, dynamic>>[];
    }
    return <Map<String, dynamic>>[payload];
  }

  Map<String, Set<String>> _readThreadTyping(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>> threadStates = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['threadStates'],
    );
    if (threadStates.isEmpty) {
      return const <String, Set<String>>{};
    }
    return <String, Set<String>>{
      for (final Map<String, dynamic> item in threadStates)
        if ((item['threadId'] ?? '').toString().trim().isNotEmpty)
          (item['threadId'] ?? '').toString().trim(): ApiPayloadReader.readStringList(
            item['typingUserIds'],
          ).where((String userId) => userId != _currentUserId).toSet(),
    };
  }

  void _setPinned(String chatId, bool value) {
    if (value) {
      _pinnedChatIds.add(chatId);
    } else {
      _pinnedChatIds.remove(chatId);
    }
    _notifySafely();
  }

  void _setArchived(String chatId, bool value) {
    if (value) {
      _archivedChatIds.add(chatId);
    } else {
      _archivedChatIds.remove(chatId);
    }
    _notifySafely();
  }

  void _setMuted(String chatId, bool value) {
    if (value) {
      _mutedChatIds.add(chatId);
    } else {
      _mutedChatIds.remove(chatId);
    }
    _notifySafely();
  }

  void _notifySafely() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  String _fallbackMessageLabel(MessageModel message) {
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
        return 'Message';
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _chatSubscription?.cancel();
    _chatSubscription = null;
    super.dispose();
  }
}
