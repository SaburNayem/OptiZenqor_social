class ChatThreadModel {
  const ChatThreadModel({
    required this.id,
    required this.title,
    required this.lastMessage,
  });

  final String id;
  final String title;
  final String lastMessage;
}
