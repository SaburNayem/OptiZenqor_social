import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class BookmarksService extends FeatureServiceBase {
  BookmarksService({super.apiClient});

  @override
  String get featureName => 'bookmarks';

  @override
  Map<String, String> get endpoints => <String, String>{
    'bookmarks': ApiEndPoints.bookmarks,
  };
}
