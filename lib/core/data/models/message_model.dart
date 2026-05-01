import '../api/api_payload_reader.dart';

class MessageModel {
  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.read,
    this.starred = false,
    this.replyToMessageId,
    this.deliveryState = 'delivered',
    this.kind = 'text',
    this.mediaPath,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool read;
  final bool starred;
  final String? replyToMessageId;
  final String deliveryState;
  final String kind;
  final String? mediaPath;

  factory MessageModel.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? lastMessage = ApiPayloadReader.readMap(
      json['lastMessage'],
    );
    final Map<String, dynamic> source = lastMessage ?? json;

    return MessageModel(
      id: ApiPayloadReader.readString(source['id'] ?? json['id']),
      chatId: ApiPayloadReader.readString(
        json['chatId'] ?? json['threadId'] ?? source['chatId'],
      ),
      senderId: ApiPayloadReader.readString(
        source['senderId'] ?? source['authorId'] ?? json['senderId'],
      ),
      text: ApiPayloadReader.readString(
        source['text'] ?? source['message'] ?? source['body'],
      ),
      timestamp:
          ApiPayloadReader.readDateTime(
            source['timestamp'] ?? source['createdAt'] ?? source['sentAt'],
          ) ??
          DateTime.now(),
      read:
          ApiPayloadReader.readBool(source['read'] ?? source['isRead']) ??
          false,
      starred:
          ApiPayloadReader.readBool(source['starred'] ?? source['isStarred']) ??
          false,
      replyToMessageId: ApiPayloadReader.readString(
        source['replyToMessageId'] ?? source['replyTo'],
      ),
      deliveryState: ApiPayloadReader.readString(
        source['deliveryState'] ?? source['status'],
        fallback: 'delivered',
      ),
      kind: ApiPayloadReader.readString(
        source['kind'] ?? source['type'],
        fallback: 'text',
      ),
      mediaPath: ApiPayloadReader.readString(
        source['mediaPath'] ?? source['mediaUrl'],
      ),
    );
  }
}
