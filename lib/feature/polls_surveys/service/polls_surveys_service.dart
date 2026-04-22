import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class PollsSurveysService extends FeatureServiceBase {
  PollsSurveysService({super.apiClient});

  @override
  String get featureName => 'polls_surveys';

  @override
  Map<String, String> get endpoints => <String, String>{
    'polls_surveys': ApiEndPoints.pollsSurveys,
    'active': ApiEndPoints.pollsSurveysActive,
    'drafts': ApiEndPoints.pollsSurveysDrafts,
    'vote': ApiEndPoints.pollsSurveyVote(':id'),
  };
}
