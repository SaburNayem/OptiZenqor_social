import 'package:flutter/material.dart';

import '../core/data/mock/mock_data.dart';
import '../features/accessibility_support/screen/accessibility_support_screen.dart';
import '../features/account_switching/screen/account_switching_screen.dart';
import '../features/activity_sessions/screen/activity_sessions_screen.dart';
import '../features/advanced_privacy_controls/screen/advanced_privacy_controls_screen.dart';
import '../features/app_update_flow/screen/app_update_flow_screen.dart';
import '../features/auth/forgot_password/screen/forgot_password_screen.dart';
import '../features/auth/forgot_password/screen/otp_verification_screen.dart';
import '../features/auth/login/screen/login_screen.dart';
import '../features/auth/reset_password/screen/reset_password_screen.dart';
import '../features/auth/signup/screen/signup_screen.dart';
import '../features/blocked_muted_accounts/screen/blocked_muted_accounts_screen.dart';
import '../features/bookmarks/screen/bookmarks_screen.dart';
import '../features/business_profile/screen/business_profile_screen.dart';
import '../features/calls/screen/calls_screen.dart';
import '../features/chat/screen/chat_screen.dart';
import '../features/communities/presentation/screens/communities_screen.dart';
import '../features/creator_tools/screen/creator_dashboard_screen.dart';
import '../features/deep_link_handler/screen/deep_link_handler_screen.dart';
import '../features/drafts_and_scheduling/screen/drafts_and_scheduling_screen.dart';
import '../features/drafts_and_scheduling/screen/drafts_screen.dart';
import '../features/drafts_and_scheduling/screen/scheduling_screen.dart';
import '../features/events/screen/events_screen.dart';
import '../features/explore_recommendation/screen/explore_recommendation_screen.dart';
import '../features/group_chat/screen/group_chat_screen.dart';
import '../features/groups/screen/groups_screen.dart';
import '../features/hashtags/screen/hashtags_screen.dart';
import '../features/home_feed/screen/main_shell_screen.dart';
import '../features/home_feed/screen/hidden_posts_screen.dart';
import '../features/invite_referral/screen/invite_referral_screen.dart';
import '../features/jobs_networking/screen/jobs_networking_screen.dart';
import '../features/learning_courses/screen/learning_courses_screen.dart';
import '../features/legal_compliance/screen/legal_compliance_screen.dart';
import '../features/live_stream/screen/live_stream_screen.dart';
import '../features/localization_support/screen/localization_support_screen.dart';
import '../features/maintenance_mode/screen/maintenance_mode_screen.dart';
import '../features/marketplace/screen/marketplace_screen.dart';
import '../features/media_viewer/screen/media_viewer_screen.dart';
import '../features/notifications/screen/notifications_screen.dart';
import '../features/offline_sync/screen/offline_sync_screen.dart';
import '../features/onboarding/screen/onboarding_screen.dart';
import '../features/pages/screen/pages_screen.dart';
import '../features/personalization_onboarding/screen/personalization_onboarding_screen.dart';
import '../features/polls_surveys/screen/polls_surveys_screen.dart';
import '../features/post_detail/screen/post_detail_screen.dart';
import '../features/premium_membership/screen/premium_membership_screen.dart';
import '../features/push_notification_preferences/screen/push_notification_preferences_screen.dart';
import '../features/report_center/screen/report_center_screen.dart';
import '../features/safety_privacy/screen/safety_privacy_screen.dart';
import '../features/saved_collections/screen/saved_collections_screen.dart';
import '../features/search_discovery/screen/search_discovery_screen.dart';
import '../features/settings/screen/about_settings_screen.dart';
import '../features/settings/screen/accessibility_settings_screen.dart';
import '../features/settings/screen/account_settings_screen.dart';
import '../features/settings/screen/archive_center_screen.dart';
import '../features/settings/screen/blocked_users_screen.dart';
import '../features/settings/screen/communities_groups_settings_screen.dart';
import '../features/settings/screen/connected_apps_screen.dart';
import '../features/settings/screen/creator_tools_settings_screen.dart';
import '../features/settings/screen/data_privacy_center_screen.dart';
import '../features/settings/screen/devices_sessions_screen.dart';
import '../features/settings/screen/feed_content_preferences_screen.dart';
import '../features/settings/screen/help_safety_settings_screen.dart';
import '../features/settings/screen/language_accessibility_screen.dart';
import '../features/settings/screen/language_region_settings_screen.dart';
import '../features/settings/screen/messages_calls_settings_screen.dart';
import '../features/settings/screen/monetization_payments_settings_screen.dart';
import '../features/settings/screen/notifications_settings_screen.dart';
import '../features/settings/screen/password_security_screen.dart';
import '../features/settings/screen/privacy_settings_screen.dart';
import '../features/settings/screen/settings_screen.dart';
import '../features/share_repost_system/screen/share_repost_system_screen.dart';
import '../features/splash/screen/splash_screen.dart';
import '../features/stories/screen/add_story_screen.dart';
import '../features/stories/screen/story_view_screen.dart';
import '../features/subscriptions/screen/subscriptions_screen.dart';
import '../features/support_help/screen/support_help_screen.dart';
import '../features/trending/screen/trending_screen.dart';
import '../features/upload_manager/screen/upload_manager_screen.dart';
import '../features/user_profile/screen/user_profile_screen.dart';
import '../features/user_profile/screen/edit_profile_screen.dart';
import '../features/verification_request/screen/verification_request_screen.dart';
import '../features/wallet_payments/screen/wallet_payments_screen.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static const initialRoute = RouteNames.splash;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Uri uri = Uri.parse(settings.name ?? RouteNames.splash);
    final String routeName = uri.path;
    final Map<String, String> params = uri.queryParameters;
    final Object? arguments = settings.arguments;

    final Widget page = _buildPage(routeName, params, arguments);

    return MaterialPageRoute<dynamic>(settings: settings, builder: (_) => page);
  }

  static Widget _buildPage(
    String routeName,
    Map<String, String> params,
    Object? arguments,
  ) {
    switch (routeName) {
      case RouteNames.splash:
        return SplashScreen();
      case RouteNames.onboarding:
        return OnboardingScreen();
      case RouteNames.login:
        return LoginScreen();
      case RouteNames.signup:
        return const SignupScreen();
      case RouteNames.forgotPassword:
        return const ForgotPasswordScreen();
      case RouteNames.otpVerification:
        return const OtpVerificationScreen();
      case RouteNames.resetPassword:
        return const ResetPasswordScreen();
      case RouteNames.shell:
        return MainShellScreen(arguments: arguments);
      case RouteNames.searchDiscovery:
        return SearchDiscoveryScreen();
      case RouteNames.communities:
        return CommunitiesScreen();
      case RouteNames.marketplace:
        return MarketplaceScreen();
      case RouteNames.notifications:
        return NotificationsScreen();
      case RouteNames.creatorDashboard:
        return const CreatorDashboardScreen();
      case RouteNames.premium:
        return PremiumMembershipScreen();
      case RouteNames.settings:
        return SettingsScreen();
      case RouteNames.accountSettings:
        return const AccountSettingsScreen();
      case RouteNames.passwordSecurity:
        return const PasswordSecurityScreen();
      case RouteNames.devicesSessions:
        return DevicesSessionsScreen();
      case RouteNames.blockedUsers:
        return BlockedUsersScreen();
      case RouteNames.archiveCenter:
        return const ArchiveCenterScreen();
      case RouteNames.privacySettings:
        return const PrivacySettingsScreen();
      case RouteNames.notificationsSettings:
        return const NotificationsSettingsScreen();
      case RouteNames.messagesCallsSettings:
        return const MessagesCallsSettingsScreen();
      case RouteNames.feedContentPreferences:
        return const FeedContentPreferencesScreen();
      case RouteNames.creatorToolsSettings:
        return const CreatorToolsSettingsScreen();
      case RouteNames.monetizationPayments:
        return const MonetizationPaymentsSettingsScreen();
      case RouteNames.communitiesGroups:
        return const CommunitiesGroupsSettingsScreen();
      case RouteNames.dataPrivacyCenter:
        return const DataPrivacyCenterScreen();
      case RouteNames.accessibilitySettings:
        return const AccessibilitySettingsScreen();
      case RouteNames.languageRegion:
        return const LanguageRegionSettingsScreen();
      case RouteNames.connectedApps:
        return const ConnectedAppsScreen();
      case RouteNames.helpSafety:
        return const HelpSafetySettingsScreen();
      case RouteNames.aboutSettings:
        return const AboutSettingsScreen();
      case RouteNames.languageAccessibility:
        return const LanguageAccessibilityScreen();
      case RouteNames.draftsScheduling:
        return DraftsAndSchedulingScreen();
      case RouteNames.drafts:
        return DraftsScreen();
      case RouteNames.scheduling:
        return SchedulingScreen();
      case RouteNames.uploadManager:
        return UploadManagerScreen();
      case RouteNames.offlineSync:
        return OfflineSyncScreen();
      case RouteNames.verificationRequest:
        return VerificationRequestScreen();
      case RouteNames.personalizationOnboarding:
        return PersonalizationOnboardingScreen();
      case RouteNames.advancedPrivacyControls:
        return AdvancedPrivacyControlsScreen();
      case RouteNames.shareRepostSystem:
        return const ShareRepostSystemScreen();
      case RouteNames.mediaViewer:
        return const MediaViewerScreen();
      case RouteNames.postDetail:
        return PostDetailScreen();
      case RouteNames.accountSwitching:
        return AccountSwitchingScreen();
      case RouteNames.pushNotificationPreferences:
        return PushNotificationPreferencesScreen();
      case RouteNames.reportCenter:
        return ReportCenterScreen();
      case RouteNames.activitySessions:
        return ActivitySessionsScreen();
      case RouteNames.deepLinkHandler:
        return const DeepLinkHandlerScreen();
      case RouteNames.appUpdateFlow:
        return AppUpdateFlowScreen();
      case RouteNames.localizationSupport:
        return LocalizationSupportScreen();
      case RouteNames.accessibilitySupport:
        return AccessibilitySupportScreen();
      case RouteNames.exploreRecommendation:
        return const ExploreRecommendationScreen();
      case RouteNames.blockedMutedAccounts:
        return BlockedMutedAccountsScreen();
      case RouteNames.maintenanceMode:
        return MaintenanceModeScreen();
      case RouteNames.inviteReferral:
        return const InviteReferralScreen();
      case RouteNames.legalCompliance:
        return LegalComplianceScreen();
      case RouteNames.groupChat:
        return GroupChatScreen();
      case RouteNames.calls:
        return CallsScreen();
      case RouteNames.groups:
        return GroupsScreen();
      case RouteNames.pages:
        return PagesScreen();
      case RouteNames.hashtags:
        return HashtagsScreen();
      case RouteNames.trending:
        return TrendingScreen();
      case RouteNames.jobsNetworking:
        return JobsNetworkingScreen();
      case RouteNames.businessProfile:
        return BusinessProfileScreen();
      case RouteNames.bookmarks:
        return BookmarksScreen();
      case RouteNames.hiddenPosts:
        return const HiddenPostsScreen();
      case RouteNames.savedCollections:
        return const SavedCollectionsScreen();
      case RouteNames.walletPayments:
        return WalletPaymentsScreen();
      case RouteNames.subscriptions:
        return SubscriptionsScreen();
      case RouteNames.events:
        return EventsScreen();
      case RouteNames.liveStream:
        return LiveStreamScreen();
      case RouteNames.safetyPrivacy:
        return SafetyPrivacyScreen();
      case RouteNames.learningCourses:
        return LearningCoursesScreen();
      case RouteNames.pollsSurveys:
        return PollsSurveysScreen();
      case RouteNames.supportHelp:
        return SupportHelpScreen();
      case RouteNames.userProfile:
        return UserProfileScreen(userId: params['id']);
      case RouteNames.userProfileEdit:
        return const EditProfileScreen();
      case RouteNames.chat:
        return ChatScreen();
      case RouteNames.storiesCreate:
        return const AddStoryScreen();
      case RouteNames.storiesView:
        return StoryViewScreen(
          stories: MockData.stories,
          users: MockData.users,
          initialStoryId: params['id'] ?? MockData.stories.first.id,
        );
      default:
        return const Scaffold(body: Center(child: Text('Route not found')));
    }
  }
}
