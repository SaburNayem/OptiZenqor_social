import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class MediaViewerService extends FeatureServiceBase {
  MediaViewerService({super.apiClient});

  @override
  String get featureName => 'media_viewer';

  @override
  Map<String, String> get endpoints => <String, String>{
    'posts': ApiEndPoints.posts,
    'reels': ApiEndPoints.reels,
    'stories': ApiEndPoints.stories,
  };
}
