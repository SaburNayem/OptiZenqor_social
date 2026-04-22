import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class VerificationRequestService extends FeatureServiceBase {
  VerificationRequestService({super.apiClient});

  @override
  String get featureName => 'verification_request';

  @override
  Map<String, String> get endpoints => <String, String>{
    'verification_request': ApiEndPoints.verificationRequest,
    'documents': ApiEndPoints.verificationRequestDocuments,
    'submit': ApiEndPoints.verificationRequestSubmit,
    'status': ApiEndPoints.verificationRequestStatus,
  };
}
