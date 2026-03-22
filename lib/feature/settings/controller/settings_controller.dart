import '../model/settings_item_model.dart';
import '../../../route/route_names.dart';

class SettingsController {
  final List<SettingsItemModel> items = const [
    SettingsItemModel(title: 'Account settings'),
    SettingsItemModel(title: 'Password and security'),
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
      title: 'Drafts and scheduling',
      routeName: RouteNames.draftsScheduling,
    ),
    SettingsItemModel(
      title: 'Upload manager',
      routeName: RouteNames.uploadManager,
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
      title: 'App update flow',
      routeName: RouteNames.appUpdateFlow,
    ),
  ];
}
