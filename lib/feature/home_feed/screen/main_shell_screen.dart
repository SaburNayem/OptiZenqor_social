import 'package:flutter/material.dart';

import '../../../route/route_names.dart';
import '../../chat/screen/chat_screen.dart';
import '../../reels_short_video/screen/reels_screen.dart';
import '../../settings/screen/settings_screen.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../controller/main_shell_controller.dart';
import 'home_feed_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  final MainShellController _controller = MainShellController();

  static const List<String> _tabTitles = [
    'Home',
    'Reels',
    'Chat',
    'Profile',
    'Settings',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('OptiZenqor • ${_tabTitles[_controller.index]}'),
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context).pushNamed(RouteNames.searchDiscovery),
                icon: const Icon(Icons.search_rounded),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pushNamed(RouteNames.notifications),
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'Notifications',
              ),
            ],
          ),
          drawer: Drawer(
            child: SafeArea(
              child: ListView(
                children: [
                  const ListTile(
                    title: Text('Feature Hub'),
                    subtitle: Text('Quick access to core modules'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.groups_rounded),
                    title: const Text('Communities'),
                    onTap: () => Navigator.of(context).pushNamed(RouteNames.communities),
                  ),
                  ListTile(
                    leading: const Icon(Icons.storefront_rounded),
                    title: const Text('Marketplace'),
                    onTap: () => Navigator.of(context).pushNamed(RouteNames.marketplace),
                  ),
                  ListTile(
                    leading: const Icon(Icons.insights_rounded),
                    title: const Text('Creator Dashboard'),
                    onTap: () => Navigator.of(context).pushNamed(RouteNames.creatorDashboard),
                  ),
                  ListTile(
                    leading: const Icon(Icons.workspace_premium_rounded),
                    title: const Text('Premium Plans'),
                    onTap: () => Navigator.of(context).pushNamed(RouteNames.premium),
                  ),
                  ListTile(
                    leading: const Icon(Icons.drafts_rounded),
                    title: const Text('Drafts & Scheduling'),
                    onTap: () => Navigator.of(context).pushNamed(RouteNames.draftsScheduling),
                  ),
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_rounded),
                    title: const Text('Upload Manager'),
                    onTap: () => Navigator.of(context).pushNamed(RouteNames.uploadManager),
                  ),
                ],
              ),
            ),
          ),
          body: KeyedSubtree(
            key: ValueKey<int>(_controller.index),
            child: _buildCurrentTab(_controller.index),
          ),
          floatingActionButton: _controller.index == 0 || _controller.index == 1
              ? FloatingActionButton.extended(
                  onPressed: () => _showCreateSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                )
              : null,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _controller.index,
            onDestinationSelected: _controller.onTabChanged,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.play_circle_outline), label: 'Reels'),
              NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
              NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
            ],
          ),
        );
      },
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: const [
            ListTile(leading: Icon(Icons.article_outlined), title: Text('Text post')),
            ListTile(leading: Icon(Icons.image_outlined), title: Text('Image post')),
            ListTile(leading: Icon(Icons.videocam_outlined), title: Text('Reel upload')),
            ListTile(leading: Icon(Icons.poll_outlined), title: Text('Poll')),
          ],
        );
      },
    );
  }

  Widget _buildCurrentTab(int index) {
    switch (index) {
      case 0:
        return const HomeFeedScreen();
      case 1:
        return const ReelsScreen();
      case 2:
        return const ChatScreen();
      case 3:
        return const UserProfileScreen();
      case 4:
        return const SettingsScreen(showAppBar: false);
      default:
        return const HomeFeedScreen();
    }
  }
}
