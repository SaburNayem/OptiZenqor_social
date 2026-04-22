import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class DeepLinkHandlerService extends FeatureServiceBase {
  DeepLinkHandlerService({super.apiClient});

  @override
  String get featureName => 'deep_link_handler';

  @override
  Map<String, String> get endpoints => <String, String>{
    'session_init': ApiEndPoints.appSessionInit,
  };
}
