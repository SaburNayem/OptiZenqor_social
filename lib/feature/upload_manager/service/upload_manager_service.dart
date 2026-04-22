import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class UploadManagerService extends FeatureServiceBase {
  UploadManagerService({super.apiClient});

  @override
  String get featureName => 'upload_manager';

  @override
  Map<String, String> get endpoints => <String, String>{
    'uploads': ApiEndPoints.uploadManager,
    'upload': ApiEndPoints.uploadManagerById(':id'),
  };
}
