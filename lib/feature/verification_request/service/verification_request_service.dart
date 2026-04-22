import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class VerificationRequestService extends FeatureServiceBase {
  VerificationRequestService({super.apiClient});

  @override
  String get featureName => 'verification_request';

  @override
  Map<String, String> get endpoints => <String, String>{
    'send_otp': ApiEndPoints.authSendOtp,
    'resend_otp': ApiEndPoints.authResendOtp,
    'verify_email_confirm': ApiEndPoints.authVerifyEmailConfirm,
  };
}
