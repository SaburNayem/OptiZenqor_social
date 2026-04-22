import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class ReportCenterService extends FeatureServiceBase {
  ReportCenterService({super.apiClient});

  @override
  String get featureName => 'report_center';

  @override
  Map<String, String> get endpoints => <String, String>{
    'support_tickets': ApiEndPoints.supportTickets,
  };
}
