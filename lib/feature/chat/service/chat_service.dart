import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class ChatService extends FeatureServiceBase {
  ChatService({super.apiClient});

  @override
  String get featureName => 'chat';

  @override
  Map<String, String> get endpoints => <String, String>{
    'threads': ApiEndPoints.chatThreads,
    'thread': ApiEndPoints.chatThreadById(':id'),
    'messages': ApiEndPoints.chatThreadMessages(':id'),
    'archive': ApiEndPoints.chatThreadArchive(':id'),
    'mute': ApiEndPoints.chatThreadMute(':id'),
    'pin': ApiEndPoints.chatThreadPin(':id'),
    'unread': ApiEndPoints.chatThreadUnread(':id'),
    'clear': ApiEndPoints.chatThreadClear(':id'),
    'presence': ApiEndPoints.chatPresence,
    'preferences': ApiEndPoints.chatPreferences,
  };
}
