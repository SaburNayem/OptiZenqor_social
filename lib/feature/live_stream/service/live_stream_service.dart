import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class LiveStreamService extends FeatureServiceBase {
  LiveStreamService({super.apiClient});

  @override
  String get featureName => 'live_stream';

  @override
  Map<String, String> get endpoints => <String, String>{
    'live_stream': ApiEndPoints.liveStream,
    'live_stream_setup': ApiEndPoints.liveStreamSetup,
    'live_stream_studio': ApiEndPoints.liveStreamStudio,
    'live_stream_detail': ApiEndPoints.liveStreamById(':id'),
    'comments': ApiEndPoints.liveStreamComments(':id'),
    'reactions': ApiEndPoints.liveStreamReactions(':id'),
    'socket_contract': ApiEndPoints.socketContract,
  };
}
