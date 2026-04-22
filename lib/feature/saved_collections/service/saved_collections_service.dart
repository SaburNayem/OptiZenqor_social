import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class SavedCollectionsService extends FeatureServiceBase {
  SavedCollectionsService({super.apiClient});

  @override
  String get featureName => 'saved_collections';

  @override
  Map<String, String> get endpoints => <String, String>{
    'collections': ApiEndPoints.savedCollections,
    'collection': ApiEndPoints.savedCollectionById(':id'),
  };
}
