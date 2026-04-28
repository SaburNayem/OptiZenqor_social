class SocketEvent {
  const SocketEvent._();

  static const connect = 'connect';
  static const connected = 'connected';
  static const disconnect = 'disconnect';
  static const reconnecting = 'reconnecting';
  static const error = 'error';

  static const message = 'message';
  static const chatMessage = 'chat.message';
  static const chatThreadUpdated = 'chat.thread.updated';
  static const chatPresence = 'chat.presence';
  static const notificationCreated = 'notification.created';
  static const notificationUpdated = 'notification.updated';

  static const aliases = <String, String>{
    'chat_message': chatMessage,
    'chat:new_message': chatMessage,
    'new_message': chatMessage,
    'thread_updated': chatThreadUpdated,
    'chat:thread_updated': chatThreadUpdated,
    'presence': chatPresence,
    'chat:presence': chatPresence,
    'notification': notificationCreated,
    'new_notification': notificationCreated,
    'notification:new': notificationCreated,
    'notification_created': notificationCreated,
    'notification_updated': notificationUpdated,
  };

  static String normalize(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return message;
    }
    return aliases[trimmed] ?? trimmed;
  }
}
