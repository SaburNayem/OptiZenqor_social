import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class OfflineSyncService extends FeatureServiceBase {
  OfflineSyncService({super.apiClient});

  @override
  String get featureName => 'offline_sync';

  @override
  Map<String, String> get endpoints => <String, String>{
    'offline_sync': ApiEndPoints.offlineSync,
    'retry': ApiEndPoints.offlineSyncRetry,
    'session_init': ApiEndPoints.appSessionInit,
    'bootstrap': ApiEndPoints.appBootstrap,
    'upload_manager': ApiEndPoints.uploadManager,
  };
}
