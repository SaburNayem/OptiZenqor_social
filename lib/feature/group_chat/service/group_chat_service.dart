import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class GroupChatService extends FeatureServiceBase {
  GroupChatService({super.apiClient});

  @override
  String get featureName => 'group_chat';

  @override
  Map<String, String> get endpoints => <String, String>{
    'group_chat': ApiEndPoints.groupChat,
  };
}
