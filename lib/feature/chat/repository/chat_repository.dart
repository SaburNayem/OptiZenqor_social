import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/message_model.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../service/chat_service.dart';

class ChatRepository {
  ChatRepository({ChatService? service}) : _service = service ?? ChatService();

  final ChatService _service;

  Future<List<MessageModel>> fetchInbox() async {
    for (final String key in <String>['threads', 'messages']) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }
        final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['threads', 'messages', 'items'],
        );
        if (items.isNotEmpty) {
          return items
              .map(MessageModel.fromApiJson)
              .where((MessageModel item) => item.chatId.isNotEmpty)
              .toList(growable: false);
        }
      } catch (_) {}
    }

    await Future<void>.delayed(const Duration(milliseconds: 220));
    return MockData.messages;
  }

  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .apiClient
          .post(
            _service.endpoints['messages']!.replaceFirst(':id', chatId),
            <String, dynamic>{'senderId': senderId, 'text': text},
          );
      if (response.isSuccess && response.data['success'] != false) {
        return MessageModel.fromApiJson(
          ApiPayloadReader.readMap(response.data['data']) ?? response.data,
        );
      }
    } catch (_) {}

    await Future<void>.delayed(const Duration(milliseconds: 200));
    return MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
      read: false,
    );
  }
}
