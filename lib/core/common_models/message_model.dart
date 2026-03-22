class MessageModel {
  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.read,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool read;
}
