import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class ReelsShortVideoService extends FeatureServiceBase {
  ReelsShortVideoService({super.apiClient});

  @override
  String get featureName => 'reels_short_video';

  @override
  Map<String, String> get endpoints => <String, String>{
    'reels': ApiEndPoints.reels,
  };
}
