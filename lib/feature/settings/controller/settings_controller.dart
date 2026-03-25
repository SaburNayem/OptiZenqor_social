import 'package:flutter/material.dart';
<<<<<<< HEAD

import '../../../core/common_data/mock_data.dart';
import '../../../core/enums/user_role.dart';
import '../../../route/route_names.dart';
import '../model/settings_item_model.dart';
import '../model/settings_section_model.dart';

class SettingsController {
  SettingsController({UserRole? role}) : _role = role ?? MockData.users.first.role;

  final UserRole _role;
=======
import 'package:get/get.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/user_model.dart';
import '../../../core/enums/user_role.dart';
import '../../../route/route_names.dart';
import '../model/settings_item_model.dart';
import '../model/settings_section_model.dart';

class SettingsController extends GetxController {
  late final UserModel currentUser;

  @override
  void onInit() {
    super.onInit();
    currentUser = MockData.users.first;
  }

  String get roleLabel => switch (currentUser.role) {
        UserRole.creator => 'Creator tools enabled',
        UserRole.business => 'Business controls enabled',
        UserRole.seller => 'Seller controls enabled',
        UserRole.recruiter => 'Recruiter controls enabled',
        _ => 'Personal account controls',
      };
>>>>>>> 08433d8 (update)

  List<SettingsSectionModel> get sections {
    return <SettingsSectionModel>[
      SettingsSectionModel(
        title: 'Account',
<<<<<<< HEAD
        description: 'Profile, identity, and account management.',
        items: const [
          SettingsItemModel(
            title: 'Account settings',
            subtitle: 'Edit profile, username, and account status',
            icon: Icons.person_outline,
            routeName: RouteNames.accountSettings,
          ),
          SettingsItemModel(
            title: 'Account switching',
            subtitle: 'Manage linked accounts',
            icon: Icons.switch_account_outlined,
            routeName: RouteNames.accountSwitching,
          ),
          SettingsItemModel(
            title: 'Verification request',
            subtitle: 'Request or manage verification',
            icon: Icons.verified_outlined,
            routeName: RouteNames.verificationRequest,
          ),
          SettingsItemModel(
            title: 'Blocked and muted accounts',
            subtitle: 'Review blocked or muted users',
            icon: Icons.block_outlined,
            routeName: RouteNames.blockedMutedAccounts,
=======
        description: 'Identity, sessions, verification, and account access.',
        items: const <SettingsItemModel>[
          SettingsItemModel(
            title: 'Account settings',
            subtitle: 'Profile, username, account type, and archive access',
            icon: Icons.person_outline_rounded,
            routeName: RouteNames.accountSettings,
          ),
          SettingsItemModel(
            title: 'Password and security',
            subtitle: 'Password, login protection, and trusted devices',
            icon: Icons.lock_outline_rounded,
            routeName: RouteNames.passwordSecurity,
          ),
          SettingsItemModel(
            title: 'Devices and sessions',
            subtitle: 'Review active devices and recent sign-ins',
            icon: Icons.devices_outlined,
            routeName: RouteNames.devicesSessions,
          ),
          SettingsItemModel(
            title: 'Verification request',
            subtitle: 'Submit or review profile verification status',
            icon: Icons.verified_user_outlined,
            routeName: RouteNames.verificationRequest,
          ),
          SettingsItemModel(
            title: 'Account switching',
            subtitle: 'Move between linked identities',
            icon: Icons.switch_account_outlined,
            routeName: RouteNames.accountSwitching,
>>>>>>> 08433d8 (update)
          ),
        ],
      ),
      SettingsSectionModel(
<<<<<<< HEAD
        title: 'Privacy & Security',
        description: 'Control visibility, safety, and security protections.',
        items: const [
          SettingsItemModel(
            title: 'Privacy',
            subtitle: 'Visibility, tagging, and sensitive content',
            icon: Icons.shield_outlined,
            routeName: RouteNames.privacySettings,
          ),
          SettingsItemModel(
            title: 'Password & security',
            subtitle: '2FA, recovery, and alerts',
            icon: Icons.lock_outline,
            routeName: RouteNames.passwordSecurity,
          ),
          SettingsItemModel(
            title: 'Active sessions',
            subtitle: 'Login history and trusted devices',
            icon: Icons.devices_outlined,
            routeName: RouteNames.activitySessions,
          ),
          SettingsItemModel(
            title: 'Report center',
            subtitle: 'Manage reports and appeals',
            icon: Icons.report_outlined,
=======
        title: 'Privacy & Safety',
        description: 'Visibility, moderation, reports, and account safety.',
        items: const <SettingsItemModel>[
          SettingsItemModel(
            title: 'Advanced privacy controls',
            subtitle: 'Mentions, tagging, discoverability, and visibility',
            icon: Icons.shield_outlined,
            routeName: RouteNames.advancedPrivacyControls,
          ),
          SettingsItemModel(
            title: 'Blocked and muted accounts',
            subtitle: 'Manage blocked, muted, and restricted users',
            icon: Icons.block_outlined,
            routeName: RouteNames.blockedMutedAccounts,
          ),
          SettingsItemModel(
            title: 'Blocked users quick list',
            subtitle: 'Jump straight into block management',
            icon: Icons.person_off_outlined,
            routeName: RouteNames.blockedUsers,
          ),
          SettingsItemModel(
            title: 'Safety and privacy',
            subtitle: 'Sensitive content, account health, and protections',
            icon: Icons.health_and_safety_outlined,
            routeName: RouteNames.safetyPrivacy,
          ),
          SettingsItemModel(
            title: 'Report center',
            subtitle: 'Track reports, strikes, and moderation outcomes',
            icon: Icons.flag_outlined,
>>>>>>> 08433d8 (update)
            routeName: RouteNames.reportCenter,
          ),
        ],
      ),
      SettingsSectionModel(
<<<<<<< HEAD
        title: 'Notifications & Messages',
        description: 'Choose how you receive alerts and messages.',
        items: const [
          SettingsItemModel(
            title: 'Notifications',
            subtitle: 'Push, email, and in-app alerts',
            icon: Icons.notifications_none_outlined,
            routeName: RouteNames.notificationsSettings,
          ),
          SettingsItemModel(
            title: 'Messages & calls',
            subtitle: 'Message requests, read receipts, call rules',
            icon: Icons.chat_bubble_outline,
            routeName: RouteNames.messagesCallsSettings,
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'Content & Feed',
        description: 'Recommendations, autoplay, and content preferences.',
        items: const [
          SettingsItemModel(
            title: 'Feed & content preferences',
            subtitle: 'Autoplay, topics, and recommendation reset',
            icon: Icons.tune_outlined,
            routeName: RouteNames.feedContentPreferences,
          ),
          SettingsItemModel(
            title: 'Explore recommendations',
            subtitle: 'Tune discovery suggestions',
            icon: Icons.explore_outlined,
            routeName: RouteNames.exploreRecommendation,
          ),
          SettingsItemModel(
            title: 'Saved collections',
            subtitle: 'Collections and bookmarks',
            icon: Icons.bookmark_border,
            routeName: RouteNames.savedCollections,
          ),
          SettingsItemModel(
            title: 'My archive',
            subtitle: 'Stories, reels, and archived content',
            icon: Icons.archive_outlined,
            routeName: RouteNames.archiveCenter,
          ),
        ],
      ),
      if (_role == UserRole.creator ||
          _role == UserRole.business ||
          _role == UserRole.seller ||
          _role == UserRole.recruiter)
        SettingsSectionModel(
          title: 'Creator & Professional Tools',
          description: 'Creator tools, professional dashboards, and growth.',
          items: const [
            SettingsItemModel(
              title: 'Creator tools',
              subtitle: 'Professional dashboards and branded content',
              icon: Icons.insights_outlined,
              routeName: RouteNames.creatorToolsSettings,
            ),
            SettingsItemModel(
              title: 'Creator dashboard',
              subtitle: 'Performance and monetization overview',
              icon: Icons.dashboard_outlined,
              routeName: RouteNames.creatorDashboard,
            ),
            SettingsItemModel(
              title: 'Jobs networking',
              subtitle: 'Recruiting and professional connections',
              icon: Icons.work_outline,
              routeName: RouteNames.jobsNetworking,
=======
        title: 'Experience',
        description: 'Notifications, language, accessibility, and feed behavior.',
        items: const <SettingsItemModel>[
          SettingsItemModel(
            title: 'Push notification preferences',
            subtitle: 'Tune activity, message, and creator alerts',
            icon: Icons.notifications_active_outlined,
            routeName: RouteNames.pushNotificationPreferences,
          ),
          SettingsItemModel(
            title: 'Explore recommendations',
            subtitle: 'Reset recommendation signals and content preferences',
            icon: Icons.tune_outlined,
            routeName: RouteNames.exploreRecommendation,
          ),
          SettingsItemModel(
            title: 'Language and accessibility',
            subtitle: 'Language, captions, and assistive options',
            icon: Icons.language_outlined,
            routeName: RouteNames.languageAccessibility,
          ),
          SettingsItemModel(
            title: 'Localization support',
            subtitle: 'Locale-aware content and translation settings',
            icon: Icons.translate_outlined,
            routeName: RouteNames.localizationSupport,
          ),
          SettingsItemModel(
            title: 'Accessibility support',
            subtitle: 'Readable UI, motion, and assistive interaction settings',
            icon: Icons.accessibility_new_outlined,
            routeName: RouteNames.accessibilitySupport,
          ),
        ],
      ),
      if (_hasProfessionalControls)
        SettingsSectionModel(
          title: 'Professional',
          description: 'Monetization, audience tools, and role-aware controls.',
          items: <SettingsItemModel>[
            if (currentUser.role == UserRole.creator)
              const SettingsItemModel(
                title: 'Creator dashboard',
                subtitle: 'Insights, growth, and creator controls',
                icon: Icons.insights_outlined,
                routeName: RouteNames.creatorDashboard,
              ),
            if (currentUser.role == UserRole.business)
              const SettingsItemModel(
                title: 'Business profile',
                subtitle: 'Page controls, brand identity, and campaigns',
                icon: Icons.business_center_outlined,
                routeName: RouteNames.businessProfile,
              ),
            const SettingsItemModel(
              title: 'Wallet and payments',
              subtitle: 'Balance, payouts, and saved payment preferences',
              icon: Icons.account_balance_wallet_outlined,
              routeName: RouteNames.walletPayments,
            ),
            const SettingsItemModel(
              title: 'Subscriptions',
              subtitle: 'Manage plans, perks, and recurring benefits',
              icon: Icons.workspace_premium_outlined,
              routeName: RouteNames.subscriptions,
            ),
            const SettingsItemModel(
              title: 'Invite and referral',
              subtitle: 'Referral rewards and shareable invite flows',
              icon: Icons.card_giftcard_outlined,
              routeName: RouteNames.inviteReferral,
>>>>>>> 08433d8 (update)
            ),
          ],
        ),
      SettingsSectionModel(
<<<<<<< HEAD
        title: 'Monetization & Payments',
        description: 'Wallets, subscriptions, and premium access.',
        items: const [
          SettingsItemModel(
            title: 'Monetization & payments',
            subtitle: 'Payout settings and subscriber badges',
            icon: Icons.payments_outlined,
            routeName: RouteNames.monetizationPayments,
          ),
          SettingsItemModel(
            title: 'Wallet',
            subtitle: 'Balance, payout methods, and history',
            icon: Icons.account_balance_wallet_outlined,
            routeName: RouteNames.walletPayments,
          ),
          SettingsItemModel(
            title: 'Subscriptions',
            subtitle: 'Subscriber tiers and benefits',
            icon: Icons.subscriptions_outlined,
            routeName: RouteNames.subscriptions,
          ),
          SettingsItemModel(
            title: 'Premium membership',
            subtitle: 'Upgrade and premium features',
            icon: Icons.workspace_premium_outlined,
            routeName: RouteNames.premium,
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'Communities',
        description: 'Groups, pages, and community management.',
        items: const [
          SettingsItemModel(
            title: 'Communities & groups',
            subtitle: 'Invites, mentions, and events',
            icon: Icons.groups_outlined,
            routeName: RouteNames.communitiesGroups,
          ),
          SettingsItemModel(
            title: 'Communities',
            subtitle: 'Manage community memberships',
            icon: Icons.forum_outlined,
            routeName: RouteNames.communities,
          ),
          SettingsItemModel(
            title: 'Groups',
            subtitle: 'Group discovery and moderation',
            icon: Icons.group_work_outlined,
            routeName: RouteNames.groups,
          ),
          SettingsItemModel(
            title: 'Pages',
            subtitle: 'Page management and insights',
            icon: Icons.pages_outlined,
            routeName: RouteNames.pages,
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'Data & Privacy Center',
        description: 'Data export, ad preferences, and privacy controls.',
        items: const [
          SettingsItemModel(
            title: 'Data & privacy center',
            subtitle: 'Download data, permissions, and cache',
            icon: Icons.storage_outlined,
            routeName: RouteNames.dataPrivacyCenter,
          ),
          SettingsItemModel(
            title: 'Offline sync',
            subtitle: 'Queued actions and downloads',
            icon: Icons.offline_bolt_outlined,
=======
        title: 'Support & App',
        description: 'Archive, app utilities, compliance, and product support.',
        items: const <SettingsItemModel>[
          SettingsItemModel(
            title: 'Archive center',
            subtitle: 'Archived posts, stories, and saved history',
            icon: Icons.archive_outlined,
            routeName: RouteNames.archiveCenter,
          ),
          SettingsItemModel(
            title: 'Offline sync',
            subtitle: 'Queued actions, retry state, and local sync health',
            icon: Icons.sync_outlined,
>>>>>>> 08433d8 (update)
            routeName: RouteNames.offlineSync,
          ),
          SettingsItemModel(
            title: 'Deep link handler',
<<<<<<< HEAD
            subtitle: 'Link routing and app associations',
            icon: Icons.link_outlined,
            routeName: RouteNames.deepLinkHandler,
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'Accessibility & Language',
        description: 'Accessibility settings and regional preferences.',
        items: const [
          SettingsItemModel(
            title: 'Accessibility',
            subtitle: 'Captions, contrast, and motion',
            icon: Icons.accessibility_new_outlined,
            routeName: RouteNames.accessibilitySettings,
          ),
          SettingsItemModel(
            title: 'Language & region',
            subtitle: 'Locale, date, and time format',
            icon: Icons.language_outlined,
            routeName: RouteNames.languageRegion,
          ),
          SettingsItemModel(
            title: 'Localization support',
            subtitle: 'Translation and localization status',
            icon: Icons.translate_outlined,
            routeName: RouteNames.localizationSupport,
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'Connected Apps',
        description: 'Manage third-party access and integrations.',
        items: const [
          SettingsItemModel(
            title: 'Connected apps',
            subtitle: 'Manage permissions and access',
            icon: Icons.extension_outlined,
            routeName: RouteNames.connectedApps,
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'Help & Safety',
        description: 'Support, safety resources, and legal information.',
        items: const [
          SettingsItemModel(
            title: 'Help & safety',
            subtitle: 'Support and safety resources',
            icon: Icons.help_outline,
            routeName: RouteNames.helpSafety,
          ),
          SettingsItemModel(
            title: 'Safety & privacy',
            subtitle: 'Safety resources and reporting',
            icon: Icons.health_and_safety_outlined,
            routeName: RouteNames.safetyPrivacy,
          ),
          SettingsItemModel(
            title: 'Legal & compliance',
            subtitle: 'Policies and legal notices',
            icon: Icons.gavel_outlined,
            routeName: RouteNames.legalCompliance,
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'About',
        description: 'App details and update information.',
        items: const [
          SettingsItemModel(
            title: 'About OptiZenqor',
            subtitle: 'Version, updates, and acknowledgements',
            icon: Icons.info_outline,
            routeName: RouteNames.aboutSettings,
          ),
          SettingsItemModel(
            title: 'App update flow',
            subtitle: 'Preview update prompts',
            icon: Icons.system_update_alt_outlined,
            routeName: RouteNames.appUpdateFlow,
          ),
          SettingsItemModel(
            title: 'Maintenance mode preview',
            subtitle: 'Preview service interruptions',
            icon: Icons.build_outlined,
=======
            subtitle: 'Inspect route entry behavior for links',
            icon: Icons.link_outlined,
            routeName: RouteNames.deepLinkHandler,
          ),
          SettingsItemModel(
            title: 'App update flow',
            subtitle: 'Preview upgrade prompts and update UX',
            icon: Icons.system_update_outlined,
            routeName: RouteNames.appUpdateFlow,
          ),
          SettingsItemModel(
            title: 'Legal and compliance',
            subtitle: 'Policies, consent, and platform compliance surfaces',
            icon: Icons.gavel_outlined,
            routeName: RouteNames.legalCompliance,
          ),
          SettingsItemModel(
            title: 'Support and help',
            subtitle: 'FAQ, help center, and safety support',
            icon: Icons.help_outline_rounded,
            routeName: RouteNames.supportHelp,
          ),
          SettingsItemModel(
            title: 'Maintenance mode preview',
            subtitle: 'Internal preview of maintenance UX',
            icon: Icons.build_circle_outlined,
>>>>>>> 08433d8 (update)
            routeName: RouteNames.maintenanceMode,
          ),
        ],
      ),
    ];
  }
<<<<<<< HEAD
=======

  bool get _hasProfessionalControls {
    return currentUser.role == UserRole.creator ||
        currentUser.role == UserRole.business ||
        currentUser.role == UserRole.seller ||
        currentUser.role == UserRole.recruiter;
  }
>>>>>>> 08433d8 (update)
}
