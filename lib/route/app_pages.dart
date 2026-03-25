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
import '../feature/bookmarks/screen/bookmarks_screen.dart';
import '../feature/business_profile/screen/business_profile_screen.dart';
import '../feature/calls/screen/calls_screen.dart';
import '../feature/chat/screen/chat_screen.dart';
import '../feature/communities/screen/communities_screen.dart';
import '../feature/creator_tools/screen/creator_dashboard_screen.dart';
import '../feature/deep_link_handler/screen/deep_link_handler_screen.dart';
import '../feature/drafts_and_scheduling/screen/drafts_and_scheduling_screen.dart';
import '../feature/drafts_and_scheduling/screen/drafts_screen.dart';
import '../feature/drafts_and_scheduling/screen/scheduling_screen.dart';
import '../feature/events/screen/events_screen.dart';
import '../feature/explore_recommendation/screen/explore_recommendation_screen.dart';
import '../feature/group_chat/screen/group_chat_screen.dart';
import '../feature/groups/screen/groups_screen.dart';
import '../feature/hashtags/screen/hashtags_screen.dart';
import '../feature/home_feed/screen/main_shell_screen.dart';
import '../feature/invite_referral/screen/invite_referral_screen.dart';
import '../feature/jobs_networking/screen/jobs_networking_screen.dart';
import '../feature/learning_courses/screen/learning_courses_screen.dart';
import '../feature/legal_compliance/screen/legal_compliance_screen.dart';
import '../feature/live_stream/screen/live_stream_screen.dart';
import '../feature/localization_support/screen/localization_support_screen.dart';
import '../feature/maintenance_mode/screen/maintenance_mode_screen.dart';
import '../feature/marketplace/screen/marketplace_screen.dart';
import '../feature/media_viewer/screen/media_viewer_screen.dart';
import '../feature/notifications/screen/notifications_screen.dart';
import '../feature/offline_sync/screen/offline_sync_screen.dart';
import '../feature/onboarding/screen/onboarding_screen.dart';
import '../feature/pages/screen/pages_screen.dart';
import '../feature/personalization_onboarding/screen/personalization_onboarding_screen.dart';
import '../feature/polls_surveys/screen/polls_surveys_screen.dart';
import '../feature/post_detail/screen/post_detail_screen.dart';
import '../feature/premium_membership/screen/premium_membership_screen.dart';
import '../feature/push_notification_preferences/screen/push_notification_preferences_screen.dart';
import '../feature/report_center/screen/report_center_screen.dart';
import '../feature/safety_privacy/screen/safety_privacy_screen.dart';
import '../feature/saved_collections/screen/saved_collections_screen.dart';
import '../feature/search_discovery/screen/search_discovery_screen.dart';
import '../feature/settings/screen/account_settings_screen.dart';
import '../feature/settings/screen/about_settings_screen.dart';
import '../feature/settings/screen/accessibility_settings_screen.dart';
import '../feature/settings/screen/archive_center_screen.dart';
import '../feature/settings/screen/blocked_users_screen.dart';
import '../feature/settings/screen/communities_groups_settings_screen.dart';
import '../feature/settings/screen/connected_apps_screen.dart';
import '../feature/settings/screen/creator_tools_settings_screen.dart';
import '../feature/settings/screen/data_privacy_center_screen.dart';
import '../feature/settings/screen/devices_sessions_screen.dart';
import '../feature/settings/screen/feed_content_preferences_screen.dart';
import '../feature/settings/screen/help_safety_settings_screen.dart';
import '../feature/settings/screen/language_accessibility_screen.dart';
import '../feature/settings/screen/language_region_settings_screen.dart';
import '../feature/settings/screen/messages_calls_settings_screen.dart';
import '../feature/settings/screen/monetization_payments_settings_screen.dart';
import '../feature/settings/screen/notifications_settings_screen.dart';
import '../feature/settings/screen/password_security_screen.dart';
import '../feature/settings/screen/privacy_settings_screen.dart';
import '../feature/settings/screen/settings_screen.dart';
import '../feature/share_repost_system/screen/share_repost_system_screen.dart';
import '../feature/splash/screen/splash_screen.dart';
import '../feature/subscriptions/screen/subscriptions_screen.dart';
import '../feature/support_help/screen/support_help_screen.dart';
import '../feature/trending/screen/trending_screen.dart';
import '../feature/upload_manager/screen/upload_manager_screen.dart';
import '../feature/user_profile/screen/user_profile_screen.dart';
import '../feature/verification_request/screen/verification_request_screen.dart';
import '../feature/wallet_payments/screen/wallet_payments_screen.dart';
import 'route_names.dart';

typedef AppPageBuilder = Widget Function();

class AppPages {
  AppPages._();

  static const initialRoute = RouteNames.splash;

  static final Map<String, AppPageBuilder> pageBuilders =
      <String, AppPageBuilder>{
        RouteNames.splash: () => SplashScreen(),
        RouteNames.onboarding: () => OnboardingScreen(),
        RouteNames.login: () => LoginScreen(),
        RouteNames.signup: () => const SignupScreen(),
        RouteNames.forgotPassword: () => const ForgotPasswordScreen(),
        RouteNames.resetPassword: () => const ResetPasswordScreen(),
        RouteNames.shell: () => MainShellScreen(),
        RouteNames.searchDiscovery: () => SearchDiscoveryScreen(),
        RouteNames.communities: () => CommunitiesScreen(),
        RouteNames.marketplace: () => MarketplaceScreen(),
        RouteNames.notifications: () => NotificationsScreen(),
        RouteNames.creatorDashboard: () => const CreatorDashboardScreen(),
        RouteNames.premium: () => PremiumMembershipScreen(),
        RouteNames.settings: () => const SettingsScreen(),
        RouteNames.accountSettings: () => const AccountSettingsScreen(),
        RouteNames.passwordSecurity: () => const PasswordSecurityScreen(),
        RouteNames.devicesSessions: () => DevicesSessionsScreen(),
        RouteNames.blockedUsers: () => BlockedUsersScreen(),
        RouteNames.archiveCenter: () => const ArchiveCenterScreen(),
        RouteNames.privacySettings: () => const PrivacySettingsScreen(),
        RouteNames.notificationsSettings: () =>
            const NotificationsSettingsScreen(),
        RouteNames.messagesCallsSettings: () =>
            const MessagesCallsSettingsScreen(),
        RouteNames.feedContentPreferences: () =>
            const FeedContentPreferencesScreen(),
        RouteNames.creatorToolsSettings: () =>
            const CreatorToolsSettingsScreen(),
        RouteNames.monetizationPayments: () =>
            const MonetizationPaymentsSettingsScreen(),
        RouteNames.communitiesGroups: () =>
            const CommunitiesGroupsSettingsScreen(),
        RouteNames.dataPrivacyCenter: () => const DataPrivacyCenterScreen(),
        RouteNames.accessibilitySettings: () =>
            const AccessibilitySettingsScreen(),
        RouteNames.languageRegion: () => const LanguageRegionSettingsScreen(),
        RouteNames.connectedApps: () => const ConnectedAppsScreen(),
        RouteNames.helpSafety: () => const HelpSafetySettingsScreen(),
        RouteNames.aboutSettings: () => const AboutSettingsScreen(),
        RouteNames.languageAccessibility: () =>
            const LanguageAccessibilityScreen(),
        RouteNames.draftsScheduling: () => DraftsAndSchedulingScreen(),
        RouteNames.drafts: () => DraftsScreen(),
        RouteNames.scheduling: () => SchedulingScreen(),
        RouteNames.uploadManager: () => UploadManagerScreen(),
        RouteNames.offlineSync: () => OfflineSyncScreen(),
        RouteNames.verificationRequest: () => VerificationRequestScreen(),
        RouteNames.personalizationOnboarding: () =>
            PersonalizationOnboardingScreen(),
        RouteNames.advancedPrivacyControls: () =>
            AdvancedPrivacyControlsScreen(),
        RouteNames.shareRepostSystem: () => const ShareRepostSystemScreen(),
        RouteNames.mediaViewer: () => const MediaViewerScreen(),
        RouteNames.postDetail: () => PostDetailScreen(),
        RouteNames.accountSwitching: () => AccountSwitchingScreen(),
        RouteNames.pushNotificationPreferences: () =>
            PushNotificationPreferencesScreen(),
        RouteNames.reportCenter: () => ReportCenterScreen(),
        RouteNames.activitySessions: () => ActivitySessionsScreen(),
        RouteNames.deepLinkHandler: () => const DeepLinkHandlerScreen(),
        RouteNames.appUpdateFlow: () => AppUpdateFlowScreen(),
        RouteNames.localizationSupport: () => LocalizationSupportScreen(),
        RouteNames.accessibilitySupport: () => AccessibilitySupportScreen(),
        RouteNames.exploreRecommendation: () =>
            const ExploreRecommendationScreen(),
        RouteNames.blockedMutedAccounts: () => BlockedMutedAccountsScreen(),
        RouteNames.maintenanceMode: () => MaintenanceModeScreen(),
        RouteNames.inviteReferral: () => const InviteReferralScreen(),
        RouteNames.legalCompliance: () => LegalComplianceScreen(),
        RouteNames.groupChat: () => GroupChatScreen(),
        RouteNames.calls: () => CallsScreen(),
        RouteNames.groups: () => GroupsScreen(),
        RouteNames.pages: () => PagesScreen(),
        RouteNames.hashtags: () => HashtagsScreen(),
        RouteNames.trending: () => TrendingScreen(),
        RouteNames.jobsNetworking: () => JobsNetworkingScreen(),
        RouteNames.businessProfile: () => BusinessProfileScreen(),
        RouteNames.bookmarks: () => BookmarksScreen(),
        RouteNames.savedCollections: () => const SavedCollectionsScreen(),
        RouteNames.walletPayments: () => WalletPaymentsScreen(),
        RouteNames.subscriptions: () => SubscriptionsScreen(),
        RouteNames.events: () => EventsScreen(),
        RouteNames.liveStream: () => LiveStreamScreen(),
        RouteNames.safetyPrivacy: () => SafetyPrivacyScreen(),
        RouteNames.learningCourses: () => LearningCoursesScreen(),
        RouteNames.pollsSurveys: () => PollsSurveysScreen(),
        RouteNames.supportHelp: () => SupportHelpScreen(),
        RouteNames.userProfile: () =>
            UserProfileScreen(userId: Get.parameters['id']),
        RouteNames.chat: () => ChatScreen(),
      };

  static List<GetPage<dynamic>> get routes {
    return pageBuilders.entries
        .map(
          (entry) => GetPage<dynamic>(
            name: entry.key,
            page: entry.value,
          ),
        )
        .toList(growable: false);
  }

  static GetPage<dynamic> get unknownRoute {
    return GetPage<dynamic>(
      name: '/not-found',
      page: () => const Scaffold(
        body: Center(child: Text('Route not found')),
      ),
    );
  }
}
