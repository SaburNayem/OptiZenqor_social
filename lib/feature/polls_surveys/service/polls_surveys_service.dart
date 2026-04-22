import '../../../core/data/service/feature_service_base.dart';

class PollsSurveysService extends FeatureServiceBase {
  PollsSurveysService({super.apiClient});

  @override
  String get featureName => 'polls_surveys';
}
