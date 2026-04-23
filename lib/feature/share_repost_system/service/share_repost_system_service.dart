import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class ShareRepostSystemService extends FeatureServiceBase {
  ShareRepostSystemService({super.apiClient});

  @override
  String get featureName => 'share_repost_system';

  @override
  Map<String, String> get endpoints => <String, String>{
    'options': ApiEndPoints.shareRepostOptions,
    'track': ApiEndPoints.shareRepostTrack,
    'posts': ApiEndPoints.posts,
    'post_detail': ApiEndPoints.postById(':id'),
  };
}
