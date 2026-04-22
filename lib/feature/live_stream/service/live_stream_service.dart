import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class LiveStreamService extends FeatureServiceBase {
  LiveStreamService({super.apiClient});

  @override
  String get featureName => 'live_stream';

  @override
  Map<String, String> get endpoints => <String, String>{
    'live_stream': ApiEndPoints.liveStream,
    'socket_contract': ApiEndPoints.socketContract,
  };
}
