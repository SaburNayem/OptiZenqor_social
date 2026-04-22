import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class EventsService extends FeatureServiceBase {
  EventsService({super.apiClient});

  @override
  String get featureName => 'events';

  @override
  Map<String, String> get endpoints => <String, String>{
    'events': ApiEndPoints.events,
  };
}
