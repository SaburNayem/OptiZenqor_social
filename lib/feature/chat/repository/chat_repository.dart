import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/models/message_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../../auth/repository/auth_repository.dart';
import '../model/chat_thread_model.dart';
import '../service/chat_service.dart';

class ChatRepository {
  ChatRepository({ChatService? service, AuthRepository? authRepository})
    : _service = service ?? ChatService(),
      _authRepository = authRepository ?? AuthRepository();

  final ChatService _service;
  final AuthRepository _authRepository;

  Future<List<ChatThreadModel>> fetchThreads() async {
    final UserModel? currentUser = await _authRepository.currentUser();
    final String currentUserId = currentUser?.id ?? '';

    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('threads');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load conversations.');
    }

    final List<Map<String, dynamic>> threadItems = ApiPayloadReader.readMapList(
      response.data,
      preferredKeys: const <String>['threads', 'data', 'items', 'results'],
    );
    if (threadItems.isEmpty) {
      throw StateError('Chat threads response did not include a data payload.');
    }

    return threadItems
        .map(
          (Map<String, dynamic> item) =>
              ChatThreadModel.fromApiJson(item, currentUserId: currentUserId),
        )
        .where((ChatThreadModel item) => item.chatId.isNotEmpty)
        .toList(growable: false);
  }

  Future<ChatThreadModel> createThread(String targetUserId) async {
    final UserModel? currentUser = await _authRepository.currentUser();
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(_service.endpoints['threads']!, <String, dynamic>{
          'targetUserId': targetUserId,
        });
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to open chat.');
    }

    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Chat thread response did not include a data payload.',
    );
    final Map<String, dynamic>? thread =
        ApiPayloadReader.readMap(data['thread']) ??
        ApiPayloadReader.readMap(data['conversation']) ??
        ApiPayloadReader.readMap(data);
    if (thread == null) {
      throw Exception('Chat thread response was empty.');
    }
    return ChatThreadModel.fromApiJson(
      thread,
      currentUserId: currentUser?.id ?? '',
    );
  }

  Future<List<MessageModel>> fetchMessages(String threadId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(_service.endpoints['messages']!.replaceFirst(':id', threadId));
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load messages.');
    }

    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      response.data,
      preferredKeys: const <String>['messages'],
    );
    return items
        .map(MessageModel.fromApiJson)
        .map((MessageModel item) {
          if (item.chatId.isNotEmpty) {
            return item;
          }
          return MessageModel(
            id: item.id,
            chatId: threadId,
            senderId: item.senderId,
            text: item.text,
            timestamp: item.timestamp,
            read: item.read,
            starred: item.starred,
            replyToMessageId: item.replyToMessageId,
            deliveryState: item.deliveryState,
            kind: item.kind,
            mediaPath: item.mediaPath,
            latitude: item.latitude,
            longitude: item.longitude,
            locationUrl: item.locationUrl,
            locationName: item.locationName,
          );
        })
        .toList(growable: false);
  }

  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String kind = 'text',
    String? mediaUrl,
    String? attachmentName,
    String? mimeType,
    String? replyToMessageId,
    double? latitude,
    double? longitude,
    String? locationUrl,
    String? locationName,
  }) async {
    final UserModel? currentUser = await _authRepository.currentUser();
    final String normalizedKind = _normalizeKind(kind);
    final String normalizedMediaUrl = (mediaUrl ?? '').trim();
    final String normalizedSenderId = senderId.trim().isNotEmpty
        ? senderId.trim()
        : (currentUser?.id ?? '').trim();
    final String normalizedText = text.trim();
    final String normalizedLocationUrl = (locationUrl ?? '').trim();
    final String normalizedLocationName = (locationName ?? '').trim();
    final bool hasLocationCoordinates = latitude != null && longitude != null;
    final Map<String, dynamic> payload = <String, dynamic>{
      'text': normalizedText,
      if (normalizedMediaUrl.isNotEmpty) 'message': normalizedText,
      'senderId': normalizedSenderId,
      if ((replyToMessageId ?? '').trim().isNotEmpty)
        'replyToMessageId': replyToMessageId!.trim(),
      if (normalizedKind != 'text') 'kind': normalizedKind,
      if (normalizedKind != 'text') 'type': normalizedKind,
      if (normalizedMediaUrl.isNotEmpty)
        'attachments': <String>[normalizedMediaUrl],
      if (normalizedMediaUrl.isNotEmpty) 'mediaUrl': normalizedMediaUrl,
      if (normalizedMediaUrl.isNotEmpty) 'mediaPath': normalizedMediaUrl,
      if (normalizedMediaUrl.isNotEmpty) 'attachmentUrl': normalizedMediaUrl,
      if (normalizedMediaUrl.isNotEmpty && normalizedKind == 'image')
        'imageUrl': normalizedMediaUrl,
      if (normalizedMediaUrl.isNotEmpty && normalizedKind == 'audio')
        'audioUrl': normalizedMediaUrl,
      if (normalizedMediaUrl.isNotEmpty && normalizedKind == 'video')
        'videoUrl': normalizedMediaUrl,
      if (normalizedMediaUrl.isNotEmpty && normalizedKind == 'file')
        'fileUrl': normalizedMediaUrl,
      if (normalizedKind == 'location' && hasLocationCoordinates)
        'latitude': latitude,
      if (normalizedKind == 'location' && hasLocationCoordinates)
        'longitude': longitude,
      if (normalizedKind == 'location' && hasLocationCoordinates)
        'lat': latitude,
      if (normalizedKind == 'location' && hasLocationCoordinates)
        'lng': longitude,
      if (normalizedKind == 'location' && normalizedLocationUrl.isNotEmpty)
        'locationUrl': normalizedLocationUrl,
      if (normalizedKind == 'location' && normalizedLocationUrl.isNotEmpty)
        'mapUrl': normalizedLocationUrl,
      if (normalizedKind == 'location' && normalizedLocationName.isNotEmpty)
        'locationName': normalizedLocationName,
      if (normalizedKind == 'location' &&
          (hasLocationCoordinates ||
              normalizedLocationUrl.isNotEmpty ||
              normalizedLocationName.isNotEmpty))
        'location': <String, dynamic>{
          if (hasLocationCoordinates) 'latitude': latitude,
          if (hasLocationCoordinates) 'longitude': longitude,
          if (hasLocationCoordinates)
            'coordinates': <double>[longitude, latitude],
          if (normalizedLocationUrl.isNotEmpty) 'url': normalizedLocationUrl,
          if (normalizedLocationName.isNotEmpty) 'name': normalizedLocationName,
        },
    };
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(
          _service.endpoints['messages']!.replaceFirst(':id', chatId),
          payload,
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to send message');
    }

    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Chat message response did not include a data payload.',
    );
    final Map<String, dynamic> messagePayload =
        ApiPayloadReader.readMap(data['message']) ??
        ApiPayloadReader.readMap(data) ??
        const <String, dynamic>{};
    final MessageModel message = MessageModel.fromApiJson(messagePayload);
    if (message.id.isEmpty) {
      throw Exception('Unable to send message');
    }
    return MessageModel(
      id: message.id,
      chatId: message.chatId.isEmpty ? chatId : message.chatId,
      senderId: message.senderId.isEmpty ? senderId : message.senderId,
      text: message.text.isEmpty ? text : message.text,
      timestamp: message.timestamp,
      read: message.read,
      starred: message.starred,
      replyToMessageId: message.replyToMessageId,
      deliveryState: message.deliveryState,
      kind: message.kind.isEmpty ? normalizedKind : message.kind,
      mediaPath: (message.mediaPath ?? '').trim().isNotEmpty
          ? message.mediaPath
          : mediaUrl,
      latitude: message.latitude ?? latitude,
      longitude: message.longitude ?? longitude,
      locationUrl: (message.locationUrl ?? '').trim().isNotEmpty
          ? message.locationUrl
          : locationUrl,
      locationName: (message.locationName ?? '').trim().isNotEmpty
          ? message.locationName
          : locationName,
    );
  }

  Future<MessageModel> editMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) async {
    final UserModel? currentUser = await _authRepository.currentUser();
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(
          ApiEndPoints.chatThreadMessageById(chatId, messageId),
          <String, dynamic>{
            'userId': currentUser?.id ?? '',
            'text': text.trim(),
          },
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to edit message.');
    }
    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Edit message response did not include data.',
    );
    return MessageModel.fromApiJson(
      ApiPayloadReader.readMap(data['message']) ?? data,
    );
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    final UserModel? currentUser = await _authRepository.currentUser();
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .delete(
          ApiEndPoints.chatThreadMessageById(chatId, messageId),
          payload: <String, dynamic>{'userId': currentUser?.id ?? ''},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to delete message.');
    }
  }

  Future<MessageModel> toggleMessagePin({
    required String chatId,
    required String messageId,
    required bool value,
  }) async {
    final UserModel? currentUser = await _authRepository.currentUser();
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(
          ApiEndPoints.chatThreadMessagePin(chatId, messageId),
          <String, dynamic>{'userId': currentUser?.id ?? '', 'value': value},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to pin message.');
    }
    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Pin message response did not include data.',
    );
    return MessageModel.fromApiJson(
      ApiPayloadReader.readMap(data['message']) ?? data,
    );
  }

  Future<MessageModel> forwardMessage({
    required String sourceChatId,
    required String messageId,
    required String targetChatId,
  }) async {
    final UserModel? currentUser = await _authRepository.currentUser();
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(
          ApiEndPoints.chatThreadMessageForward(sourceChatId, messageId),
          <String, dynamic>{
            'userId': currentUser?.id ?? '',
            'targetThreadId': targetChatId,
          },
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to forward message.');
    }
    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Forward message response did not include data.',
    );
    return MessageModel.fromApiJson(
      ApiPayloadReader.readMap(data['message']) ?? data,
    );
  }

  Future<Map<String, Map<String, dynamic>>> fetchThreadPreferences() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('preferences');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load chat preferences.');
    }

    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage:
          'Chat preferences response did not include a data payload.',
    );
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      data,
      preferredKeys: const <String>['conversationPreferences'],
    );
    return <String, Map<String, dynamic>>{
      for (final Map<String, dynamic> item in items)
        ApiPayloadReader.readString(item['threadId']): item,
    }..remove('');
  }

  Future<Map<String, dynamic>> fetchPresenceSnapshot() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('presence');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load presence.');
    }
    return ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Chat presence response did not include a data payload.',
    );
  }

  Future<Map<String, dynamic>> updateTypingPresence({
    required String threadId,
    required bool isTyping,
  }) async {
    final UserModel? currentUser = await _authRepository.currentUser();
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(_service.endpoints['presence']!, <String, dynamic>{
          'userId': currentUser?.id ?? '',
          'online': isTyping,
          'typingInThreadId': threadId,
        });
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to update typing state.');
    }
    return ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage:
          'Chat presence update response did not include a data payload.',
    );
  }

  Future<void> markThreadRead(String threadId) async {
    final UserModel? currentUser = await _authRepository.currentUser();
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(
          _service.endpoints['read']!.replaceFirst(':id', threadId),
          <String, dynamic>{'userId': currentUser?.id ?? ''},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to mark thread as read.');
    }
  }

  Future<Map<String, dynamic>> updateThreadPreference({
    required String threadId,
    required String action,
    required bool value,
  }) async {
    final UserModel? currentUser = await _authRepository.currentUser();
    final String? endpoint = _service.endpoints[action];
    if (endpoint == null) {
      throw ArgumentError.value(action, 'action', 'Unsupported chat action.');
    }
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(endpoint.replaceFirst(':id', threadId), <String, dynamic>{
          'userId': currentUser?.id ?? '',
          'value': value,
        });
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to update chat preference.');
    }
    return ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage:
          'Chat preference response did not include a data payload.',
    );
  }

  String _normalizeKind(String kind) {
    switch (kind.trim().toLowerCase()) {
      case 'gallery':
      case 'camera':
      case 'image':
      case 'photo':
        return 'image';
      case 'voice':
      case 'audio':
        return 'audio';
      case 'document':
      case 'file':
        return 'file';
      case 'video':
        return 'video';
      case 'location':
        return 'location';
      case 'contact':
        return 'contact';
      default:
        return 'text';
    }
  }
}
