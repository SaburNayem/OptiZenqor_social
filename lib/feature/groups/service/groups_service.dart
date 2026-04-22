import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class GroupsService extends FeatureServiceBase {
  GroupsService({super.apiClient});

  @override
  String get featureName => 'groups';

  @override
  Map<String, String> get endpoints => <String, String>{
    'groups': ApiEndPoints.groups,
  };
}
