import 'package:flutter/material.dart';

import '../../../app_route/route_names.dart';
import '../../../core/common_widget/app_avatar.dart';
import '../../../core/navigation/app_get.dart';
import '../controller/main_shell_controller.dart';
import 'main_shell_drawer_section.dart';

class MainShellDrawer extends StatelessWidget {
  const MainShellDrawer({
    super.key,
    required this.controller,
  });

  final MainShellController controller;

  @override
  Widget build(BuildContext context) {
    final currentUser = controller.currentUser;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: AppAvatar(
                imageUrl: currentUser.avatar,
                radius: 28,
              ),
              accountName: Text(currentUser.name),
              accountEmail: Text('@${currentUser.username}'),
              margin: EdgeInsets.zero,
              onDetailsPressed: () => AppGet.toNamed(
                RouteNames.userProfile,
                parameters: <String, String>{'id': currentUser.id},
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
                  const _MainShellDrawerItem(
                    icon: Icons.logout,
                    label: 'Log Out',
                    routeName: RouteNames.login,
                    isDestructive: true,
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
}

class _MainShellDrawerItem extends StatelessWidget {
  const _MainShellDrawerItem({
    required this.icon,
    required this.label,
    required this.routeName,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String routeName;
  final bool isDestructive;

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
      onTap: () {
        AppGet.back();
        AppGet.toNamed(routeName);
      },
    );
  }
}
