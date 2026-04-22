import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/message_model.dart';

class ChatRepository {
  Future<List<MessageModel>> fetchInbox() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return MockData.messages;
  }

  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
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
