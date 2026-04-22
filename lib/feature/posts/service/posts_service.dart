import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class PostsService extends FeatureServiceBase {
  PostsService({super.apiClient});

  @override
  String get featureName => 'posts';

  @override
  Map<String, String> get endpoints => <String, String>{
    'posts': ApiEndPoints.posts,
    'post': ApiEndPoints.postById(':id'),
    'like': ApiEndPoints.postLike(':id'),
    'comments': ApiEndPoints.postComments(':id'),
  };
}
