import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class CallsService extends FeatureServiceBase {
  CallsService({super.apiClient});

  @override
  String get featureName => 'calls';

  @override
  Map<String, String> get endpoints => <String, String>{
    'calls': ApiEndPoints.calls,
  };
}
