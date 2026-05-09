import '../../../core/data/api/api_payload_reader.dart';
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

    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Chat threads response did not include a data payload.',
    );
    return ApiPayloadReader.readMapList(
          data,
          preferredKeys: const <String>['threads'],
        )
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

    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Chat messages response did not include a data payload.',
    );
    return ApiPayloadReader.readMapList(
          data,
          preferredKeys: const <String>['messages'],
        )
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
          );
        })
        .toList(growable: false);
  }

  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(
          _service.endpoints['messages']!.replaceFirst(':id', chatId),
          <String, dynamic>{'text': text},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to send message');
    }

    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Chat message response did not include a data payload.',
    );
    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(data['message']) ??
        ApiPayloadReader.readMap(data) ??
        const <String, dynamic>{};
    final MessageModel message = MessageModel.fromApiJson(payload);
    if (message.id.isEmpty) {
      throw Exception('Unable to send message');
    }
    return message;
  }
}
