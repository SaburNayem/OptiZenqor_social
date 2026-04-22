import '../../../core/data/service/feature_service_base.dart';

class AccessibilitySupportService extends FeatureServiceBase {
  AccessibilitySupportService({super.apiClient});

  @override
  String get featureName => 'accessibility_support';
}
