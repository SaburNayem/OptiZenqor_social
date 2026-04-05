import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/service/connectivity_service.dart';
import '../../../route/route_names.dart';
import '../../chat/screen/chat_screen.dart';
import '../../reels_short_video/screen/reels_screen.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../controller/main_shell_controller.dart';
import 'create_post_screen.dart';
import 'home_feed_screen.dart';

class MainShellScreen extends StatelessWidget {
  MainShellScreen({super.key, this.arguments}) {
    _controller = MainShellController(arguments: arguments);
    _connectivity = ConnectivityService();
  }

  final Object? arguments;
  late final MainShellController _controller;
  late final ConnectivityService _connectivity;

  @override
  Widget build(BuildContext context) {
    final currentUser = MockData.users.first;

    return BlocProvider<MainShellController>.value(
      value: _controller,
      child: BlocBuilder<MainShellController, int>(
        builder: (context, _) {
        final controller = _controller;
        final tabs = <Widget>[
          HomeFeedScreen(),
          ReelsScreen(),
          const SizedBox.shrink(), // Placeholder for center FAB action
          ChatScreen(),
          UserProfileScreen(showAppBar: false),
        ];

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: controller.index == 1 ? null : AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: const Text(''),
            actions: <Widget>[
              IconButton(
                onPressed: () => AppGet.toNamed(RouteNames.searchDiscovery),
                icon: const Icon(Icons.search_rounded, color: Colors.black87),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () => AppGet.toNamed(RouteNames.notifications),
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(currentUser.avatar),
                ),
              ),
            ],
          ),
          drawer: Drawer(
            child: SafeArea(
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(currentUser.avatar),
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
                        _buildDrawerItem(Icons.groups_outlined, 'Communities', RouteNames.communities),
                        _buildDrawerItem(Icons.shopping_bag_outlined, 'Marketplace', RouteNames.marketplace),
                        _buildDrawerItem(Icons.bar_chart_outlined, 'Creator Dashboard', RouteNames.creatorDashboard),
                        _buildDrawerItem(Icons.star_outline, 'Premium Plans', RouteNames.premium),
                        _buildDrawerItem(Icons.calendar_today_outlined, 'Drafts & Scheduling', RouteNames.scheduling),
                        _buildDrawerItem(Icons.cloud_upload_outlined, 'Upload Manager', RouteNames.uploadManager),
                        _buildDrawerItem(Icons.bookmark_border_outlined, 'Bookmarks', RouteNames.bookmarks),
                        _buildDrawerItem(Icons.account_balance_wallet_outlined, 'Wallet', RouteNames.walletPayments),
                        _buildDrawerItem(Icons.event_outlined, 'Events', RouteNames.events),
                        _buildDrawerItem(Icons.work_outline, 'Jobs', RouteNames.jobsNetworking),
                        _buildDrawerItem(Icons.card_giftcard_outlined, 'Invite Friends', RouteNames.inviteReferral),
                        _buildDrawerItem(Icons.archive_outlined, 'My archive', RouteNames.archiveCenter),
                        const Divider(),
                        _buildDrawerItem(Icons.settings_outlined, 'Settings', RouteNames.settings),
                        _buildDrawerItem(Icons.help_outline, 'Help & Support', RouteNames.supportHelp),
                        _buildDrawerItem(Icons.logout, 'Log Out', RouteNames.login, isDestructive: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              AnimatedBuilder(
                animation: _connectivity,
                builder: (_, _) {
                  if (_connectivity.isOnline) {
                    return const SizedBox.shrink();
                  }
                  return MaterialBanner(
                    content: const Text('You are offline.'),
                    leading: const Icon(Icons.wifi_off_rounded),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => _connectivity.setOnline(true),
                        child: const Text('Go online'),
                      ),
                    ],
                  );
                },
              ),
              Expanded(
                child: IndexedStack(
                  index: controller.index,
                  children: tabs,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openCreateScreen(context),
            backgroundColor: const Color(0xFF26C6DA),
            shape: const CircleBorder(),
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            padding: EdgeInsets.zero,
            height: 70,
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: controller.index == 0,
                  onTap: () => controller.onTabChanged(0),
                ),
                _NavBarItem(
                  icon: Icons.play_circle_outline,
                  activeIcon: Icons.play_circle_filled_rounded,
                  label: 'Reels',
                  isSelected: controller.index == 1,
                  onTap: () => controller.onTabChanged(1),
                ),
                const SizedBox(width: 48), // Space for FAB
                _NavBarItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  isSelected: controller.index == 3,
                  onTap: () => controller.onTabChanged(3),
                ),
                _NavBarItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: controller.index == 4,
                  onTap: () => controller.onTabChanged(4),
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, String routeName, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.blueGrey.shade700),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.blueGrey.shade800,
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

  Future<void> _openCreateScreen(BuildContext context) async {
    final CreatePostResult? result =
        await Navigator.of(context).push<CreatePostResult>(
      MaterialPageRoute<CreatePostResult>(
        builder: (_) => CreatePostScreen(),
      ),
    );
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Post created')));
    }
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF26C6DA) : Colors.grey.shade400;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
