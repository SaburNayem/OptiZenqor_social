import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/service/theme_service.dart';
import '../../../app_route/route_names.dart';
import '../../bookmarks/controller/bookmarks_controller.dart';
import '../../home_feed/controller/home_feed_controller.dart';
import '../../home_feed/controller/main_shell_controller.dart';
import '../controller/settings_controller.dart';
import '../model/settings_item_model.dart';
import '../model/settings_section_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainShellController, int>(
      builder: (context, _) {
        final SettingsController controller = SettingsController(
          currentUser: context.read<MainShellController>().currentUser,
        );
        final theme = Theme.of(context);
        final sections = _displaySections(controller);

        return Scaffold(
          backgroundColor: AppColors.hexFFF8F8FA,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                _topBar(context, controller),
                const SizedBox(height: 18),
                _profileCard(context, controller),
                const SizedBox(height: 18),
                ...sections.map(
                  (section) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _sectionCard(context, section),
                  ),
                ),
                const SizedBox(height: 6),
                _logoutButton(context),
                const SizedBox(height: 14),
                Text(
                  'OptiZenqor Socity Version 2.4.1',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hexFFB4B7C1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topBar(BuildContext context, SettingsController controller) {
    final actions = [
      _TopAction(
        icon: Icons.search_rounded,
        onTap: () => _showSnack(context, 'Search settings coming soon'),
      ),
      _TopAction(
        icon: Icons.notifications_none_rounded,
        onTap: () => AppGet.toNamed(RouteNames.notifications),
      ),
    ];

    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        Expanded(
          child: Text(
            'Settings',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        ...actions.map(
          (action) =>
              IconButton(onPressed: action.onTap, icon: Icon(action.icon)),
        ),
        CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(controller.currentUser.avatar),
        ),
      ],
    );
  }

  Widget _profileCard(BuildContext context, SettingsController controller) {
    final user = controller.currentUser;

    return InkWell(
      onTap: () => AppGet.toNamed(RouteNames.accountSettings),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.hexFFECECF1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(user.avatar),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.hexFF8A8E99,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.hexFFB5B8C1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context, _SettingsDisplaySection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            section.title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.hexFF9A9EAA,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.hexFFECECF1),
          ),
          child: Column(
            children: [
              for (var i = 0; i < section.items.length; i++) ...[
                _settingsRow(context, section.items[i]),
                if (i != section.items.length - 1)
                  const Divider(height: 1, indent: 68, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingsRow(BuildContext context, SettingsItemModel item) {
    final iconColor = _iconColor(item.title);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          item.icon ?? Icons.settings_outlined,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        item.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: item.isDestructive
              ? Theme.of(context).colorScheme.error
              : AppColors.hexFF303542,
        ),
      ),
      subtitle: item.subtitle == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                item.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.hexFF9599A5),
              ),
            ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.hexFFB5B8C1,
      ),
      onTap: () => _handleItemTap(context, item),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _logout(context),
      icon: const Icon(Icons.logout_rounded),
      label: const Text('Log Out'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.hexFFFF5A55,
        side: const BorderSide(color: AppColors.hexFFFFD7D5),
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<MainShellController>().logout();
    if (!context.mounted) {
      return;
    }
    context.read<HomeFeedController>().clearLocalState();
    context.read<BookmarksController>().clearLocalState();
    AppGet.offAllNamed(RouteNames.login);
  }

  List<_SettingsDisplaySection> _displaySections(
    SettingsController controller,
  ) {
    final sectionMap = {
      for (final section in controller.sections) section.title: section,
    };

    final accountItems = _takeItems(sectionMap['Account'], [
      'Account settings',
      'Password and security',
    ]);
    final privacyItems = _takeItems(sectionMap['Privacy & Safety'], null);
    final connectionItems = _mergeItems([
      _takeItems(sectionMap['Communities & Discoverability'], [
        'Communities & groups',
        'Connected apps',
        'Deep link handler',
        'Invite and referral',
      ]),
    ]);
    final preferenceItems = _mergeItems([
      _takeItems(sectionMap['Messages, Calls & Notifications'], [
        'Notifications',
        'Notification categories',
        'Messages & calls',
      ]),
      _takeItems(sectionMap['Language, Accessibility & Data'], [
        'Language and accessibility',
        'Language & region',
        'Accessibility',
        'Localization support',
        'Accessibility support',
      ]),
      [_themeItem()],
    ]);
    final contentItems = _takeItems(sectionMap['Content & Feed'], null);
    final professionalItems = _takeItems(sectionMap['Professional'], null);
    final appItems = _mergeItems([
      _takeItems(sectionMap['Account'], [
        'Devices and sessions',
        'Verification request',
        'Account switching',
        'Archive center',
      ]),
      _takeItems(sectionMap['Messages, Calls & Notifications'], [
        'Activity sessions',
      ]),
      _takeItems(sectionMap['Language, Accessibility & Data'], [
        'Data & privacy center',
        'Offline sync',
      ]),
      _takeItems(sectionMap['About & App'], null),
    ]);

    return [
      if (accountItems.isNotEmpty)
        _SettingsDisplaySection(title: 'Account', items: accountItems),
      if (privacyItems.isNotEmpty)
        _SettingsDisplaySection(title: 'Privacy', items: privacyItems),
      if (connectionItems.isNotEmpty)
        _SettingsDisplaySection(title: 'Connections', items: connectionItems),
      if (preferenceItems.isNotEmpty)
        _SettingsDisplaySection(title: 'Preferences', items: preferenceItems),
      if (contentItems.isNotEmpty)
        _SettingsDisplaySection(title: 'Content', items: contentItems),
      if (professionalItems.isNotEmpty)
        _SettingsDisplaySection(
          title: 'Professional',
          items: professionalItems,
        ),
      if (appItems.isNotEmpty)
        _SettingsDisplaySection(title: 'App', items: appItems),
    ];
  }

  List<SettingsItemModel> _mergeItems(List<List<SettingsItemModel>> groups) {
    return groups.expand((group) => group).toList(growable: false);
  }

  List<SettingsItemModel> _takeItems(
    SettingsSectionModel? section,
    List<String>? titles,
  ) {
    if (section == null) return const [];
    if (titles == null) return section.items;

    return titles
        .map((title) => _findItem(section.items, title))
        .whereType<SettingsItemModel>()
        .toList(growable: false);
  }

  SettingsItemModel _themeItem() {
    return const SettingsItemModel(
      title: 'Theme mode',
      subtitle: 'Switch between light, dark, and system theme',
      icon: Icons.palette_outlined,
    );
  }

  SettingsItemModel? _findItem(List<SettingsItemModel> items, String title) {
    for (final item in items) {
      if (item.title == title) return item;
    }
    return null;
  }

  Color _iconColor(String title) {
    final key = title.toLowerCase();
    if (key.contains('account') || key.contains('personal')) {
      return AppColors.primary600;
    }
    if (key.contains('password') || key.contains('security')) {
      return AppColors.primary700;
    }
    if (key.contains('privacy')) {
      return AppColors.primary500;
    }
    if (key.contains('blocked')) {
      return AppColors.primary800;
    }
    if (key.contains('connected')) {
      return AppColors.primary500;
    }
    if (key.contains('notification')) {
      return AppColors.primary600;
    }
    if (key.contains('language')) {
      return AppColors.primary600;
    }
    if (key.contains('accessibility')) {
      return AppColors.primary500;
    }
    if (key.contains('devices') || key.contains('session')) {
      return AppColors.grey700;
    }
    if (key.contains('support') || key.contains('help')) {
      return AppColors.grey700;
    }
    return AppColors.primary700;
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleItemTap(BuildContext context, SettingsItemModel item) {
    if (item.title == 'Theme mode') {
      _showThemeSheet(context);
      return;
    }

    if (item.routeName != null) {
      AppGet.toNamed(item.routeName!);
    }
  }

  Future<void> _showThemeSheet(BuildContext context) async {
    final current = ThemeService.instance.mode.value;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values
                .map(
                  (mode) => ListTile(
                    title: Text(mode.name),
                    trailing: current == mode
                        ? Icon(
                            Icons.check_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      ThemeService.instance.setTheme(mode);
                      Navigator.of(context).pop();
                    },
                  ),
                )
                .toList(growable: false),
          ),
        );
      },
    );
  }
}

class _SettingsDisplaySection {
  const _SettingsDisplaySection({required this.title, required this.items});

  final String title;
  final List<SettingsItemModel> items;
}

class _TopAction {
  const _TopAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;
}
