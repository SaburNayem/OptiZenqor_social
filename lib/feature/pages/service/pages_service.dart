import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class PagesService extends FeatureServiceBase {
  PagesService({super.apiClient});

  @override
  String get featureName => 'pages';

  @override
  Map<String, String> get endpoints => <String, String>{
    'pages': ApiEndPoints.pages,
    'page': ApiEndPoints.pageById(':id'),
  };
}
