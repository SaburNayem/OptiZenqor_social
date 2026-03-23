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
}
