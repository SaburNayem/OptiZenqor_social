import 'package:flutter/material.dart';

import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/enums/user_role.dart';
import '../../../app_route/route_names.dart';
import '../model/settings_item_model.dart';
import '../model/settings_section_model.dart';

class SettingsController {
  SettingsController() : currentUser = MockData.users.first;

  final UserModel currentUser;

  String get roleLabel => switch (currentUser.role) {
        UserRole.creator => 'Creator tools enabled',
        UserRole.business => 'Business controls enabled',
        UserRole.seller => 'Seller controls enabled',
        UserRole.recruiter => 'Recruiter controls enabled',
        _ => 'Personal account controls',
      };

  List<SettingsSectionModel> get sections {
    return <SettingsSectionModel>[
      SettingsSectionModel(
        title: 'Account',
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
          ),
          SettingsItemModel(
            title: 'Archive center',
            subtitle: 'Archived posts, stories, and saved history',
            icon: Icons.archive_outlined,
            routeName: RouteNames.archiveCenter,
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'Privacy & Safety',
        description: 'Visibility, moderation, reports, and account safety.',
        items: const <SettingsItemModel>[
          SettingsItemModel(
            title: 'Privacy',
            subtitle: 'Visibility, tagging, and sensitive content',
            icon: Icons.shield_outlined,
            routeName: RouteNames.privacySettings,
          ),
          SettingsItemModel(
            title: 'Advanced privacy controls',
            subtitle: 'Mentions, tagging, discoverability, and visibility',
            icon: Icons.manage_accounts_outlined,
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
            routeName: RouteNames.reportCenter,
          ),
          SettingsItemModel(
            title: 'Help & safety',
            subtitle: 'Appeals, help flows, and platform support',
            icon: Icons.support_agent_outlined,
            routeName: RouteNames.helpSafety,
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'Messages, Calls & Notifications',
        description: 'Tune alerts, messaging privacy, and call controls.',
        items: const <SettingsItemModel>[
          SettingsItemModel(
            title: 'Notifications',
            subtitle: 'Push, email, and in-app alerts',
            icon: Icons.notifications_active_outlined,
            routeName: RouteNames.notificationsSettings,
          ),
          SettingsItemModel(
            title: 'Notification categories',
            subtitle: 'Fine-tune post, comment, and mention alerts',
            icon: Icons.tune_outlined,
            routeName: RouteNames.pushNotificationPreferences,
          ),
          SettingsItemModel(
            title: 'Messages & calls',
            subtitle: 'Requests, read receipts, downloads, and calling',
            icon: Icons.chat_bubble_outline,
            routeName: RouteNames.messagesCallsSettings,
          ),
          SettingsItemModel(
            title: 'Activity sessions',
            subtitle: 'Review session history and security events',
            icon: Icons.history_toggle_off_outlined,
            routeName: RouteNames.activitySessions,
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'Content & Feed',
        description: 'Recommendations, autoplay, drafts, and discovery controls.',
        items: const <SettingsItemModel>[
          SettingsItemModel(
            title: 'Feed & content preferences',
            subtitle: 'Autoplay, topics, and recommendation reset',
            icon: Icons.view_stream_outlined,
            routeName: RouteNames.feedContentPreferences,
          ),
          SettingsItemModel(
            title: 'Explore recommendations',
            subtitle: 'Reset recommendation signals and content preferences',
            icon: Icons.explore_outlined,
            routeName: RouteNames.exploreRecommendation,
          ),
          SettingsItemModel(
            title: 'Saved collections',
            subtitle: 'Collections and bookmarks',
            icon: Icons.collections_bookmark_outlined,
            routeName: RouteNames.savedCollections,
          ),
          SettingsItemModel(
            title: 'Drafts & scheduling',
            subtitle: 'Manage unpublished and scheduled content',
            icon: Icons.edit_calendar_outlined,
            routeName: RouteNames.draftsScheduling,
          ),
        ],
      ),
      if (_hasProfessionalControls)
        SettingsSectionModel(
          title: 'Professional',
          description: 'Monetization, audience tools, and role-aware controls.',
          items: <SettingsItemModel>[
            const SettingsItemModel(
              title: 'Creator / professional tools',
              subtitle: 'Professional dashboards and branded content settings',
              icon: Icons.insights_outlined,
              routeName: RouteNames.creatorToolsSettings,
            ),
            if (currentUser.role == UserRole.creator)
              const SettingsItemModel(
                title: 'Creator dashboard',
                subtitle: 'Insights, growth, and creator controls',
                icon: Icons.dashboard_outlined,
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
              title: 'Monetization & payments',
              subtitle: 'Payout settings and subscriber badges',
              icon: Icons.payments_outlined,
              routeName: RouteNames.monetizationPayments,
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
              title: 'Premium membership',
              subtitle: 'Upgrade and premium features',
              icon: Icons.stars_outlined,
              routeName: RouteNames.premium,
            ),
          ],
        ),
      SettingsSectionModel(
        title: 'Communities & Discoverability',
        description: 'Groups, pages, communities, and public presence.',
        items: const <SettingsItemModel>[
          SettingsItemModel(
            title: 'Communities & groups',
            subtitle: 'Invites, mentions, and events',
            icon: Icons.groups_outlined,
            routeName: RouteNames.communitiesGroups,
          ),
          SettingsItemModel(
            title: 'Connected apps',
            subtitle: 'Linked services and integrations',
            icon: Icons.extension_outlined,
            routeName: RouteNames.connectedApps,
          ),
          SettingsItemModel(
            title: 'Deep link handler',
            subtitle: 'Inspect route entry behavior for links',
            icon: Icons.link_outlined,
            routeName: RouteNames.deepLinkHandler,
          ),
          SettingsItemModel(
            title: 'Invite and referral',
            subtitle: 'Referral rewards and shareable invite flows',
            icon: Icons.card_giftcard_outlined,
            routeName: RouteNames.inviteReferral,
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'Language, Accessibility & Data',
        description: 'Locale, accessibility, privacy center, and device behavior.',
        items: const <SettingsItemModel>[
          SettingsItemModel(
            title: 'Language and accessibility',
            subtitle: 'Language, captions, and assistive options',
            icon: Icons.language_outlined,
            routeName: RouteNames.languageAccessibility,
          ),
          SettingsItemModel(
            title: 'Language & region',
            subtitle: 'Region-aware formatting and translation controls',
            icon: Icons.public_outlined,
            routeName: RouteNames.languageRegion,
          ),
          SettingsItemModel(
            title: 'Accessibility',
            subtitle: 'Readable UI, motion, and assistive interaction settings',
            icon: Icons.accessibility_new_outlined,
            routeName: RouteNames.accessibilitySettings,
          ),
          SettingsItemModel(
            title: 'Localization support',
            subtitle: 'Locale-aware content and translation settings',
            icon: Icons.translate_outlined,
            routeName: RouteNames.localizationSupport,
          ),
          SettingsItemModel(
            title: 'Accessibility support',
            subtitle: 'Additional accessibility preview and support tools',
            icon: Icons.assistant_direction_outlined,
            routeName: RouteNames.accessibilitySupport,
          ),
          SettingsItemModel(
            title: 'Data & privacy center',
            subtitle: 'Data export, cache, permissions, and privacy history',
            icon: Icons.privacy_tip_outlined,
            routeName: RouteNames.dataPrivacyCenter,
          ),
          SettingsItemModel(
            title: 'Offline sync',
            subtitle: 'Queued actions, retry state, and local sync health',
            icon: Icons.sync_outlined,
            routeName: RouteNames.offlineSync,
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'About & App',
        description: 'Legal, updates, app support, and diagnostics.',
        items: const <SettingsItemModel>[
          SettingsItemModel(
            title: 'Support and help',
            subtitle: 'FAQ, help center, and safety support',
            icon: Icons.help_outline_rounded,
            routeName: RouteNames.supportHelp,
          ),
          SettingsItemModel(
            title: 'About',
            subtitle: 'Version, licenses, and release notes',
            icon: Icons.info_outline_rounded,
            routeName: RouteNames.aboutSettings,
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
            title: 'Maintenance mode preview',
            subtitle: 'Internal preview of maintenance UX',
            icon: Icons.build_circle_outlined,
            routeName: RouteNames.maintenanceMode,
          ),
        ],
      ),
    ];
  }

  bool get _hasProfessionalControls {
    return currentUser.role == UserRole.creator ||
        currentUser.role == UserRole.business ||
        currentUser.role == UserRole.seller ||
        currentUser.role == UserRole.recruiter;
  }
}

