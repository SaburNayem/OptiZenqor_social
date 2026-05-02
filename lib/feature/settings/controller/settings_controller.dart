import 'package:flutter/material.dart';

import '../../../app_route/route_names.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/enums/user_role.dart';
import '../model/settings_item_model.dart';
import '../model/settings_section_model.dart';

class SettingsController {
  const SettingsController({required this.sections, this.currentUser});

  final UserModel? currentUser;
  final List<SettingsSectionModel> sections;

  bool get isAuthenticated => currentUser?.id.trim().isNotEmpty == true;

  String get roleLabel => switch (currentUser?.role) {
    UserRole.creator => 'Creator tools enabled',
    UserRole.business => 'Business controls enabled',
    UserRole.seller => 'Seller controls enabled',
    UserRole.recruiter => 'Recruiter controls enabled',
    UserRole.user => 'Personal account controls',
    _ => 'Sign in to manage account settings',
  };

  bool get hasProfessionalControls => switch (currentUser?.role) {
    UserRole.creator ||
    UserRole.business ||
    UserRole.seller ||
    UserRole.recruiter => true,
    _ => false,
  };

  String get displayName {
    final String resolved = currentUser?.name.trim() ?? '';
    return resolved.isEmpty ? 'Account unavailable' : resolved;
  }

  String get displayUsername {
    final String resolved = currentUser?.username.trim() ?? '';
    return resolved.isEmpty ? 'Sign in required' : '@$resolved';
  }

  String? get avatarUrl {
    final String resolved = currentUser?.avatar.trim() ?? '';
    return resolved.isEmpty ? null : resolved;
  }

  IconData iconForItem(SettingsItemModel item) {
    final String route = item.routeName?.trim() ?? '';
    switch (route) {
      case RouteNames.accountSettings:
        return Icons.person_outline_rounded;
      case RouteNames.passwordSecurity:
        return Icons.lock_outline_rounded;
      case RouteNames.devicesSessions:
        return Icons.devices_outlined;
      case RouteNames.verificationRequest:
        return Icons.verified_user_outlined;
      case RouteNames.accountSwitching:
        return Icons.switch_account_outlined;
      case RouteNames.archiveCenter:
        return Icons.archive_outlined;
      case RouteNames.privacySettings:
        return Icons.shield_outlined;
      case RouteNames.advancedPrivacyControls:
        return Icons.manage_accounts_outlined;
      case RouteNames.blockedMutedAccounts:
        return Icons.block_outlined;
      case RouteNames.blockedUsers:
        return Icons.person_off_outlined;
      case RouteNames.safetyPrivacy:
        return Icons.health_and_safety_outlined;
      case RouteNames.reportCenter:
        return Icons.flag_outlined;
      case RouteNames.helpSafety:
      case RouteNames.supportHelp:
        return Icons.support_agent_outlined;
      case RouteNames.notificationsSettings:
        return Icons.notifications_active_outlined;
      case RouteNames.pushNotificationPreferences:
        return Icons.tune_outlined;
      case RouteNames.messagesCallsSettings:
        return Icons.chat_bubble_outline;
      case RouteNames.activitySessions:
        return Icons.history_toggle_off_outlined;
      case RouteNames.feedContentPreferences:
        return Icons.view_stream_outlined;
      case RouteNames.exploreRecommendation:
        return Icons.explore_outlined;
      case RouteNames.savedCollections:
        return Icons.collections_bookmark_outlined;
      case RouteNames.draftsScheduling:
        return Icons.edit_calendar_outlined;
      case RouteNames.creatorToolsSettings:
        return Icons.insights_outlined;
      case RouteNames.creatorDashboard:
        return Icons.dashboard_outlined;
      case RouteNames.businessProfile:
        return Icons.business_center_outlined;
      case RouteNames.monetizationPayments:
        return Icons.payments_outlined;
      case RouteNames.walletPayments:
        return Icons.account_balance_wallet_outlined;
      case RouteNames.subscriptions:
        return Icons.workspace_premium_outlined;
      case RouteNames.premium:
        return Icons.stars_outlined;
      case RouteNames.communitiesGroups:
        return Icons.groups_outlined;
      case RouteNames.connectedApps:
        return Icons.extension_outlined;
      case RouteNames.deepLinkHandler:
        return Icons.link_outlined;
      case RouteNames.inviteReferral:
        return Icons.card_giftcard_outlined;
      case RouteNames.languageAccessibility:
        return Icons.language_outlined;
      case RouteNames.languageRegion:
        return Icons.public_outlined;
      case RouteNames.accessibilitySettings:
        return Icons.accessibility_new_outlined;
      case RouteNames.localizationSupport:
        return Icons.translate_outlined;
      case RouteNames.accessibilitySupport:
        return Icons.assistant_direction_outlined;
      case RouteNames.dataPrivacyCenter:
        return Icons.privacy_tip_outlined;
      case RouteNames.offlineSync:
        return Icons.sync_outlined;
      case RouteNames.aboutSettings:
        return Icons.info_outline_rounded;
      case RouteNames.appUpdateFlow:
        return Icons.system_update_outlined;
      case RouteNames.legalCompliance:
        return Icons.gavel_outlined;
      case RouteNames.maintenanceMode:
        return Icons.build_circle_outlined;
      default:
        return item.icon ?? Icons.settings_outlined;
    }
  }
}
