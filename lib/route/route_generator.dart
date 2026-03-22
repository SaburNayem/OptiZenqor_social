import 'package:flutter/material.dart';

import '../feature/accessibility_support/screen/accessibility_support_screen.dart';
import '../feature/account_switching/screen/account_switching_screen.dart';
import '../feature/activity_sessions/screen/activity_sessions_screen.dart';
import '../feature/advanced_privacy_controls/screen/advanced_privacy_controls_screen.dart';
import '../feature/app_update_flow/screen/app_update_flow_screen.dart';
import '../feature/auth/forgot_password/screen/forgot_password_screen.dart';
import '../feature/auth/login/screen/login_screen.dart';
import '../feature/auth/reset_password/screen/reset_password_screen.dart';
import '../feature/auth/signup/screen/signup_screen.dart';
import '../feature/communities/screen/communities_screen.dart';
import '../feature/creator_tools/screen/creator_dashboard_screen.dart';
import '../feature/deep_link_handler/screen/deep_link_handler_screen.dart';
import '../feature/drafts_and_scheduling/screen/drafts_and_scheduling_screen.dart';
import '../feature/explore_recommendation/screen/explore_recommendation_screen.dart';
import '../feature/invite_referral/screen/invite_referral_screen.dart';
import '../feature/legal_compliance/screen/legal_compliance_screen.dart';
import '../feature/localization_support/screen/localization_support_screen.dart';
import '../feature/main_shell/screen/main_shell_screen.dart';
import '../feature/marketplace/screen/marketplace_screen.dart';
import '../feature/maintenance_mode/screen/maintenance_mode_screen.dart';
import '../feature/media_viewer/screen/media_viewer_screen.dart';
import '../feature/offline_sync/screen/offline_sync_screen.dart';
import '../feature/notifications/screen/notifications_screen.dart';
import '../feature/onboarding/screen/onboarding_screen.dart';
import '../feature/personalization_onboarding/screen/personalization_onboarding_screen.dart';
import '../feature/post_detail/screen/post_detail_screen.dart';
import '../feature/premium_membership/screen/premium_membership_screen.dart';
import '../feature/push_notification_preferences/screen/push_notification_preferences_screen.dart';
import '../feature/report_center/screen/report_center_screen.dart';
import '../feature/search_discovery/screen/search_discovery_screen.dart';
import '../feature/settings/screen/settings_screen.dart';
import '../feature/settings/screen/account_settings_screen.dart';
import '../feature/settings/screen/password_security_screen.dart';
import '../feature/settings/screen/devices_sessions_screen.dart';
import '../feature/settings/screen/blocked_users_screen.dart';
import '../feature/settings/screen/language_accessibility_screen.dart';
import '../feature/share_repost_system/screen/share_repost_system_screen.dart';
import '../feature/splash/screen/splash_screen.dart';
import '../feature/upload_manager/screen/upload_manager_screen.dart';
import '../feature/verification_request/screen/verification_request_screen.dart';
import '../feature/blocked_muted_accounts/screen/blocked_muted_accounts_screen.dart';
import 'route_names.dart';

class RouteGenerator {
  RouteGenerator._();

  static const initialRoute = RouteNames.splash;

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _buildRoute(SplashScreen(), settings);
      case RouteNames.onboarding:
        return _buildRoute(OnboardingScreen(), settings);
      case RouteNames.login:
        return _buildRoute(LoginScreen(), settings);
      case RouteNames.signup:
        return _buildRoute(const SignupScreen(), settings);
      case RouteNames.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);
      case RouteNames.resetPassword:
        return _buildRoute(const ResetPasswordScreen(), settings);
      case RouteNames.shell:
        return _buildRoute(const AppMainShellScreen(), settings);
      case RouteNames.searchDiscovery:
        return _buildRoute(SearchDiscoveryScreen(), settings);
      case RouteNames.communities:
        return _buildRoute(CommunitiesScreen(), settings);
      case RouteNames.marketplace:
        return _buildRoute(MarketplaceScreen(), settings);
      case RouteNames.notifications:
        return _buildRoute(NotificationsScreen(), settings);
      case RouteNames.creatorDashboard:
        return _buildRoute(const CreatorDashboardScreen(), settings);
      case RouteNames.premium:
        return _buildRoute(PremiumMembershipScreen(), settings);
      case RouteNames.settings:
        return _buildRoute(const SettingsScreen(), settings);
      case RouteNames.accountSettings:
        return _buildRoute(const AccountSettingsScreen(), settings);
      case RouteNames.passwordSecurity:
        return _buildRoute(const PasswordSecurityScreen(), settings);
      case RouteNames.devicesSessions:
        return _buildRoute(const DevicesSessionsScreen(), settings);
      case RouteNames.blockedUsers:
        return _buildRoute(const BlockedUsersScreen(), settings);
      case RouteNames.languageAccessibility:
        return _buildRoute(const LanguageAccessibilityScreen(), settings);
      case RouteNames.draftsScheduling:
        return _buildRoute(DraftsAndSchedulingScreen(), settings);
      case RouteNames.uploadManager:
        return _buildRoute(UploadManagerScreen(), settings);
      case RouteNames.offlineSync:
        return _buildRoute(OfflineSyncScreen(), settings);
      case RouteNames.verificationRequest:
        return _buildRoute(VerificationRequestScreen(), settings);
      case RouteNames.personalizationOnboarding:
        return _buildRoute(PersonalizationOnboardingScreen(), settings);
      case RouteNames.advancedPrivacyControls:
        return _buildRoute(AdvancedPrivacyControlsScreen(), settings);
      case RouteNames.shareRepostSystem:
        return _buildRoute(const ShareRepostSystemScreen(), settings);
      case RouteNames.mediaViewer:
        return _buildRoute(const MediaViewerScreen(), settings);
      case RouteNames.postDetail:
        return _buildRoute(PostDetailScreen(), settings);
      case RouteNames.accountSwitching:
        return _buildRoute(AccountSwitchingScreen(), settings);
      case RouteNames.pushNotificationPreferences:
        return _buildRoute(PushNotificationPreferencesScreen(), settings);
      case RouteNames.reportCenter:
        return _buildRoute(ReportCenterScreen(), settings);
      case RouteNames.activitySessions:
        return _buildRoute(const ActivitySessionsScreen(), settings);
      case RouteNames.deepLinkHandler:
        return _buildRoute(const DeepLinkHandlerScreen(), settings);
      case RouteNames.appUpdateFlow:
        return _buildRoute(AppUpdateFlowScreen(), settings);
      case RouteNames.localizationSupport:
        return _buildRoute(LocalizationSupportScreen(), settings);
      case RouteNames.accessibilitySupport:
        return _buildRoute(AccessibilitySupportScreen(), settings);
      case RouteNames.exploreRecommendation:
        return _buildRoute(const ExploreRecommendationScreen(), settings);
      case RouteNames.blockedMutedAccounts:
        return _buildRoute(BlockedMutedAccountsScreen(), settings);
      case RouteNames.maintenanceMode:
        return _buildRoute(MaintenanceModeScreen(), settings);
      case RouteNames.inviteReferral:
        return _buildRoute(const InviteReferralScreen(), settings);
      case RouteNames.legalCompliance:
        return _buildRoute(LegalComplianceScreen(), settings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route found for ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }
}
