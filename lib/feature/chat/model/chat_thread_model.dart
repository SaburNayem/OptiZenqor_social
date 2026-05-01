import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/models/message_model.dart';
import '../../../core/data/models/user_model.dart';

class ChatThreadModel {
  const ChatThreadModel({
    required this.id,
    required this.chatId,
    required this.title,
    required this.lastMessage,
    required this.user,
    this.lastMessageModel,
    this.unreadCount = 0,
  });

  final String id;
  final String chatId;
  final String title;
  final String lastMessage;
  final UserModel user;
  final MessageModel? lastMessageModel;
  final int unreadCount;

  factory ChatThreadModel.fromApiJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final List<Map<String, dynamic>> participantMaps =
        ApiPayloadReader.readMapListFromAny(
          json['participants'],
          preferredKeys: const <String>['participants'],
        );
    final List<UserModel> participants = participantMaps
        .map(UserModel.fromApiJson)
        .where((UserModel item) => item.id.isNotEmpty)
        .toList(growable: false);
    final UserModel fallbackUser = participants.isNotEmpty
        ? participants.first
        : UserModel.fromApiJson(
            ApiPayloadReader.readMap(json['user']) ?? const <String, dynamic>{},
          );
    final UserModel threadUser =
        participants
            .where((UserModel item) => item.id != currentUserId)
            .firstOrNull ??
        fallbackUser;
    final MessageModel? lastMessageModel =
        ApiPayloadReader.readMap(json['lastMessage']) == null
        ? null
        : MessageModel.fromApiJson(json);

    return ChatThreadModel(
      id: ApiPayloadReader.readString(
        json['id'] ?? json['threadId'] ?? json['chatId'],
      ),
      chatId: ApiPayloadReader.readString(
        json['chatId'] ?? json['threadId'] ?? json['id'],
      ),
      title: ApiPayloadReader.readString(
        json['title'] ?? threadUser.name,
        fallback: threadUser.name.isEmpty ? 'Conversation' : threadUser.name,
      ),
      lastMessage:
          lastMessageModel?.text ??
          ApiPayloadReader.readString(
            json['summary'] ?? json['lastMessageText'],
            fallback: 'Start chatting',
          ),
      user: threadUser,
      lastMessageModel: lastMessageModel,
      unreadCount: ApiPayloadReader.readInt(json['unreadCount']),
    );
  }
}
