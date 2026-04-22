import 'package:flutter/foundation.dart';

import '../../../core/data/models/load_state_model.dart';
import '../../../core/data/models/message_model.dart';
import '../../../core/data/service/analytics_service.dart';
import '../model/chat_inbox_filter_model.dart';
import '../repository/chat_repository.dart';

class ChatController extends ChangeNotifier {
  ChatController({ChatRepository? repository, AnalyticsService? analytics})
    : _repository = repository ?? ChatRepository(),
      _analytics = analytics ?? AnalyticsService();

  final ChatRepository _repository;
  final AnalyticsService _analytics;

  LoadStateModel state = const LoadStateModel();
  List<MessageModel> messages = <MessageModel>[];
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

  List<MessageModel> get inboxMessages {
    final visible = messages
        .where((MessageModel m) => !_archivedChatIds.contains(m.chatId))
        .toList();
    visible.sort((MessageModel a, MessageModel b) {
      final bool aPinned = _pinnedChatIds.contains(a.chatId);
      final bool bPinned = _pinnedChatIds.contains(b.chatId);
      if (aPinned == bPinned) {
        return b.timestamp.compareTo(a.timestamp);
      }
      return aPinned ? -1 : 1;
    });
    return visible;
  }

  int unreadCount(String chatId) {
    return messages.where((m) => m.chatId == chatId && !m.read).length;
  }

  Future<void> loadChats() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();
    try {
      messages = await _repository.fetchInbox();
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        isEmpty: messages.isEmpty,
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
    messages = messages.where((message) => message.chatId != chatId).toList();
    _pinnedChatIds.remove(chatId);
    _archivedChatIds.remove(chatId);
    _retryChatIds.remove(chatId);
    notifyListeners();
  }
}
