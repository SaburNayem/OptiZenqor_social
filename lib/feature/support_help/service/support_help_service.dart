import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class SupportHelpService extends FeatureServiceBase {
  SupportHelpService({super.apiClient});

  @override
  String get featureName => 'support_help';

  @override
  Map<String, String> get endpoints => <String, String>{
    'faqs': ApiEndPoints.supportFaqs,
    'tickets': ApiEndPoints.supportTickets,
    'chat': ApiEndPoints.supportChat,
  };
}
