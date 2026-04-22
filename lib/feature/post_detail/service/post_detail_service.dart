import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class PostDetailService extends FeatureServiceBase {
  PostDetailService({super.apiClient});

  @override
  String get featureName => 'post_detail';

  @override
  Map<String, String> get endpoints => <String, String>{
    'post': ApiEndPoints.postById(':id'),
    'detail': ApiEndPoints.postDetail(':id'),
    'like': ApiEndPoints.postLike(':id'),
    'comments': ApiEndPoints.postComments(':id'),
  };
}
