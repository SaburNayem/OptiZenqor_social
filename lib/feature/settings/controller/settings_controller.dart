import '../model/settings_item_model.dart';
import '../../../route/route_names.dart';

class SettingsController {
  final List<SettingsItemModel> items = const [
    SettingsItemModel(
      title: 'Account settings',
      routeName: RouteNames.accountSettings,
    ),
    SettingsItemModel(
      title: 'Password and security',
      routeName: RouteNames.passwordSecurity,
    ),
    SettingsItemModel(
      title: 'Push notification preferences',
      routeName: RouteNames.pushNotificationPreferences,
    ),
    SettingsItemModel(
      title: 'Advanced privacy controls',
      routeName: RouteNames.advancedPrivacyControls,
    ),
    SettingsItemModel(
      title: 'Verification request',
      routeName: RouteNames.verificationRequest,
    ),
    SettingsItemModel(
      title: 'Account switching',
      routeName: RouteNames.accountSwitching,
    ),
    SettingsItemModel(
      title: 'My archive',
      routeName: RouteNames.archiveCenter,
    ),
    SettingsItemModel(
      title: 'Offline sync',
      routeName: RouteNames.offlineSync,
    ),
    SettingsItemModel(
      title: 'Activity and sessions',
      routeName: RouteNames.activitySessions,
    ),
    SettingsItemModel(
      title: 'Report center',
      routeName: RouteNames.reportCenter,
    ),
    SettingsItemModel(
      title: 'Deep link handler',
      routeName: RouteNames.deepLinkHandler,
    ),
    SettingsItemModel(
      title: 'Localization support',
      routeName: RouteNames.localizationSupport,
    ),
    SettingsItemModel(
      title: 'Accessibility support',
      routeName: RouteNames.accessibilitySupport,
    ),
    SettingsItemModel(
      title: 'Explore recommendations',
      routeName: RouteNames.exploreRecommendation,
    ),
    SettingsItemModel(
      title: 'Blocked and muted accounts',
      routeName: RouteNames.blockedMutedAccounts,
    ),
    SettingsItemModel(
      title: 'Invite and referral',
      routeName: RouteNames.inviteReferral,
    ),
    SettingsItemModel(
      title: 'Legal and compliance',
      routeName: RouteNames.legalCompliance,
    ),
    SettingsItemModel(
      title: 'Maintenance mode preview',
      routeName: RouteNames.maintenanceMode,
    ),
    SettingsItemModel(
      title: 'App update flow',
      routeName: RouteNames.appUpdateFlow,
    ),
    SettingsItemModel(
      title: 'Language and accessibility',
      routeName: RouteNames.languageAccessibility,
    ),
    SettingsItemModel(
      title: 'Devices and sessions',
      routeName: RouteNames.devicesSessions,
    ),
    SettingsItemModel(
      title: 'Trending',
      routeName: RouteNames.trending,
    ),
    SettingsItemModel(
      title: 'Jobs networking',
      routeName: RouteNames.jobsNetworking,
    ),
    SettingsItemModel(
      title: 'Business profile',
      routeName: RouteNames.businessProfile,
    ),
    SettingsItemModel(
      title: 'Wallet',
      routeName: RouteNames.walletPayments,
    ),
    SettingsItemModel(
      title: 'Subscriptions',
      routeName: RouteNames.subscriptions,
    ),
    SettingsItemModel(
      title: 'Safety and privacy',
      routeName: RouteNames.safetyPrivacy,
    ),
    SettingsItemModel(
      title: 'Learning courses',
      routeName: RouteNames.learningCourses,
    ),
    SettingsItemModel(
      title: 'Polls and surveys',
      routeName: RouteNames.pollsSurveys,
    ),
    SettingsItemModel(
      title: 'Support and help',
      routeName: RouteNames.supportHelp,
    ),
  ];
}
