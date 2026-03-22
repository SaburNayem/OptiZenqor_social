import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../feature/accessibility_support/screen/accessibility_support_screen.dart';
import '../feature/account_switching/screen/account_switching_screen.dart';
import '../feature/activity_sessions/screen/activity_sessions_screen.dart';
import '../feature/advanced_privacy_controls/screen/advanced_privacy_controls_screen.dart';
import '../feature/app_update_flow/screen/app_update_flow_screen.dart';
import '../feature/auth/forgot_password/screen/forgot_password_screen.dart';
import '../feature/auth/login/screen/login_screen.dart';
import '../feature/auth/reset_password/screen/reset_password_screen.dart';
import '../feature/auth/signup/screen/signup_screen.dart';
import '../feature/blocked_muted_accounts/screen/blocked_muted_accounts_screen.dart';
import '../feature/communities/screen/communities_screen.dart';
import '../feature/creator_tools/screen/creator_dashboard_screen.dart';
import '../feature/deep_link_handler/screen/deep_link_handler_screen.dart';
import '../feature/drafts_and_scheduling/screen/drafts_and_scheduling_screen.dart';
import '../feature/explore_recommendation/screen/explore_recommendation_screen.dart';
import '../feature/invite_referral/screen/invite_referral_screen.dart';
import '../feature/legal_compliance/screen/legal_compliance_screen.dart';
import '../feature/localization_support/screen/localization_support_screen.dart';
import '../feature/main_shell/screen/main_shell_screen.dart';
import '../feature/maintenance_mode/screen/maintenance_mode_screen.dart';
import '../feature/marketplace/screen/marketplace_screen.dart';
import '../feature/media_viewer/screen/media_viewer_screen.dart';
import '../feature/notifications/screen/notifications_screen.dart';
import '../feature/offline_sync/screen/offline_sync_screen.dart';
import '../feature/onboarding/screen/onboarding_screen.dart';
import '../feature/personalization_onboarding/screen/personalization_onboarding_screen.dart';
import '../feature/post_detail/screen/post_detail_screen.dart';
import '../feature/premium_membership/screen/premium_membership_screen.dart';
import '../feature/push_notification_preferences/screen/push_notification_preferences_screen.dart';
import '../feature/report_center/screen/report_center_screen.dart';
import '../feature/search_discovery/screen/search_discovery_screen.dart';
import '../feature/settings/screen/account_settings_screen.dart';
import '../feature/settings/screen/blocked_users_screen.dart';
import '../feature/settings/screen/devices_sessions_screen.dart';
import '../feature/settings/screen/language_accessibility_screen.dart';
import '../feature/settings/screen/password_security_screen.dart';
import '../feature/settings/screen/settings_screen.dart';
import '../feature/share_repost_system/screen/share_repost_system_screen.dart';
import '../feature/splash/screen/splash_screen.dart';
import '../feature/upload_manager/screen/upload_manager_screen.dart';
import '../feature/verification_request/screen/verification_request_screen.dart';
import 'route_names.dart';

class AppRoute {
  AppRoute._();

  // Auth and Entry
  static const String splash = RouteNames.splash;
  static const String onboarding = RouteNames.onboarding;
  static const String login = RouteNames.login;
  static const String signup = RouteNames.signup;
  static const String forgotPassword = RouteNames.forgotPassword;
  static const String resetPassword = RouteNames.resetPassword;
  static const String shell = RouteNames.shell;

  // Core Product
  static const String searchDiscovery = RouteNames.searchDiscovery;
  static const String communities = RouteNames.communities;
  static const String marketplace = RouteNames.marketplace;
  static const String notifications = RouteNames.notifications;
  static const String creatorDashboard = RouteNames.creatorDashboard;
  static const String premium = RouteNames.premium;
  static const String settings = RouteNames.settings;

  // Settings Sub Routes
  static const String accountSettings = RouteNames.accountSettings;
  static const String passwordSecurity = RouteNames.passwordSecurity;
  static const String devicesSessions = RouteNames.devicesSessions;
  static const String blockedUsers = RouteNames.blockedUsers;
  static const String languageAccessibility = RouteNames.languageAccessibility;

  // Advanced
  static const String draftsScheduling = RouteNames.draftsScheduling;
  static const String uploadManager = RouteNames.uploadManager;
  static const String offlineSync = RouteNames.offlineSync;
  static const String verificationRequest = RouteNames.verificationRequest;
  static const String personalizationOnboarding = RouteNames.personalizationOnboarding;
  static const String advancedPrivacyControls = RouteNames.advancedPrivacyControls;
  static const String shareRepostSystem = RouteNames.shareRepostSystem;
  static const String mediaViewer = RouteNames.mediaViewer;
  static const String postDetail = RouteNames.postDetail;
  static const String accountSwitching = RouteNames.accountSwitching;
  static const String pushNotificationPreferences = RouteNames.pushNotificationPreferences;
  static const String reportCenter = RouteNames.reportCenter;
  static const String activitySessions = RouteNames.activitySessions;
  static const String deepLinkHandler = RouteNames.deepLinkHandler;
  static const String appUpdateFlow = RouteNames.appUpdateFlow;
  static const String localizationSupport = RouteNames.localizationSupport;
  static const String accessibilitySupport = RouteNames.accessibilitySupport;
  static const String exploreRecommendation = RouteNames.exploreRecommendation;
  static const String blockedMutedAccounts = RouteNames.blockedMutedAccounts;
  static const String maintenanceMode = RouteNames.maintenanceMode;
  static const String inviteReferral = RouteNames.inviteReferral;
  static const String legalCompliance = RouteNames.legalCompliance;

  static const String initialRoute = splash;

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    // Auth and Entry
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: onboarding, page: () => OnboardingScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: resetPassword, page: () => const ResetPasswordScreen()),
    GetPage(name: shell, page: () => const AppMainShellScreen()),

    // Core Product
    GetPage(name: searchDiscovery, page: () => SearchDiscoveryScreen()),
    GetPage(name: communities, page: () => CommunitiesScreen()),
    GetPage(name: marketplace, page: () => MarketplaceScreen()),
    GetPage(name: notifications, page: () => NotificationsScreen()),
    GetPage(name: creatorDashboard, page: () => const CreatorDashboardScreen()),
    GetPage(name: premium, page: () => PremiumMembershipScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),

    // Settings Sub Routes
    GetPage(name: accountSettings, page: () => const AccountSettingsScreen()),
    GetPage(name: passwordSecurity, page: () => const PasswordSecurityScreen()),
    GetPage(name: devicesSessions, page: () => const DevicesSessionsScreen()),
    GetPage(name: blockedUsers, page: () => const BlockedUsersScreen()),
    GetPage(name: languageAccessibility, page: () => const LanguageAccessibilityScreen()),

    // Advanced
    GetPage(name: draftsScheduling, page: () => DraftsAndSchedulingScreen()),
    GetPage(name: uploadManager, page: () => UploadManagerScreen()),
    GetPage(name: offlineSync, page: () => OfflineSyncScreen()),
    GetPage(name: verificationRequest, page: () => VerificationRequestScreen()),
    GetPage(name: personalizationOnboarding, page: () => PersonalizationOnboardingScreen()),
    GetPage(name: advancedPrivacyControls, page: () => AdvancedPrivacyControlsScreen()),
    GetPage(name: shareRepostSystem, page: () => const ShareRepostSystemScreen()),
    GetPage(name: mediaViewer, page: () => const MediaViewerScreen()),
    GetPage(name: postDetail, page: () => PostDetailScreen()),
    GetPage(name: accountSwitching, page: () => AccountSwitchingScreen()),
    GetPage(name: pushNotificationPreferences, page: () => PushNotificationPreferencesScreen()),
    GetPage(name: reportCenter, page: () => ReportCenterScreen()),
    GetPage(name: activitySessions, page: () => const ActivitySessionsScreen()),
    GetPage(name: deepLinkHandler, page: () => const DeepLinkHandlerScreen()),
    GetPage(name: appUpdateFlow, page: () => AppUpdateFlowScreen()),
    GetPage(name: localizationSupport, page: () => LocalizationSupportScreen()),
    GetPage(name: accessibilitySupport, page: () => AccessibilitySupportScreen()),
    GetPage(name: exploreRecommendation, page: () => const ExploreRecommendationScreen()),
    GetPage(name: blockedMutedAccounts, page: () => BlockedMutedAccountsScreen()),
    GetPage(name: maintenanceMode, page: () => MaintenanceModeScreen()),
    GetPage(name: inviteReferral, page: () => const InviteReferralScreen()),
    GetPage(name: legalCompliance, page: () => LegalComplianceScreen()),
  ];

  static final GetPage<dynamic> unknownRoute = GetPage<dynamic>(
    name: '/not-found',
    page: () => const Scaffold(
      body: Center(
        child: Text('Route not found'),
      ),
    ),
  );
}
