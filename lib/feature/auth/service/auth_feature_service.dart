import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class AuthFeatureService extends FeatureServiceBase {
  AuthFeatureService({super.apiClient});

  @override
  String get featureName => 'auth';

  @override
  Map<String, String> get endpoints => <String, String>{
    'login': ApiEndPoints.authLogin,
    'signup': ApiEndPoints.authSignup,
    'forgot_password': ApiEndPoints.authForgotPassword,
    'reset_password': ApiEndPoints.authResetPassword,
    'send_otp': ApiEndPoints.authSendOtp,
    'resend_otp': ApiEndPoints.authResendOtp,
    'verify_otp': ApiEndPoints.authVerifyOtp,
    'verify_email_confirm': ApiEndPoints.authVerifyEmailConfirm,
    'me': ApiEndPoints.authMe,
  };
}
