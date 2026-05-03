import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_route/route_names.dart';
import '../../../core/common_widget/app_avatar.dart';
import '../../../core/navigation/app_get.dart';
import '../../bookmarks/controller/bookmarks_controller.dart';
import '../controller/main_shell_controller.dart';
import '../controller/home_feed_controller.dart';
import 'main_shell_drawer_section.dart';

class MainShellDrawer extends StatelessWidget {
  const MainShellDrawer({super.key, required this.controller});

  final MainShellController controller;

  @override
  Widget build(BuildContext context) {
    final currentUser = controller.currentUser;
    final String profileId = currentUser?.id ?? '';
    final String name = currentUser?.name.trim().isNotEmpty == true
        ? currentUser!.name
        : 'Signed out';
    final String username = currentUser?.username.trim().isNotEmpty == true
        ? '@${currentUser!.username}'
        : 'Sign in required';
    final String avatarUrl = currentUser?.avatar ?? '';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: AppAvatar(
                imageUrl: avatarUrl,
                radius: 28,
              ),
              accountName: Text(name),
              accountEmail: Text(username),
              margin: EdgeInsets.zero,
              onDetailsPressed: profileId.isEmpty
                  ? null
                  : () => AppGet.toNamed(
                      RouteNames.userProfile,
                      parameters: <String, String>{'id': profileId},
                    ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...controller.drawerSections.map(
                    (section) => MainShellDrawerSection(
                      section: section,
                      onTap: _openRoute,
                    ),
                  ),
                  const Divider(),
                  _MainShellDrawerItem(
                    icon: Icons.people_outline_rounded,
                    label: 'Buddy',
                    routeName: RouteNames.buddy,
                  ),
                  _MainShellDrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    routeName: RouteNames.settings,
                  ),
                  _MainShellDrawerItem(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    routeName: RouteNames.supportHelp,
                  ),
                  const Divider(),
                  _MainShellDrawerItem(
                    icon: Icons.logout,
                    label: 'Log Out',
                    routeName: RouteNames.login,
                    isDestructive: true,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRoute(String routeName) {
    AppGet.back();
    AppGet.toNamed(routeName);
  }

  Future<void> _logout(BuildContext context) async {
    final HomeFeedController homeFeedController = context
        .read<HomeFeedController>();
    final BookmarksController bookmarksController = context
        .read<BookmarksController>();
    AppGet.back();
    await controller.logout();
    homeFeedController.clearLocalState();
    bookmarksController.clearLocalState();
    AppGet.offAllNamed(RouteNames.login);
  }
}

class _MainShellDrawerItem extends StatelessWidget {
  const _MainShellDrawerItem({
    required this.icon,
    required this.label,
    required this.routeName,
    this.isDestructive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String routeName;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDestructive ? Colors.red : Colors.black87;

    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      onTap:
          onTap ??
          () {
            AppGet.back();
            AppGet.toNamed(routeName);
          },
    );
  }
}
