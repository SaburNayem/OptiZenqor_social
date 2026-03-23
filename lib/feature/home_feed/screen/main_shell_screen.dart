import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/connectivity_service.dart';
import '../../../route/route_names.dart';
import '../../chat/screen/chat_screen.dart';
import '../../reels_short_video/screen/reels_screen.dart';
import '../../settings/screen/settings_screen.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../controller/main_shell_controller.dart';
import 'create_post_screen.dart';
import 'home_feed_screen.dart';

class MainShellScreen extends StatelessWidget {
  MainShellScreen({super.key}) {
    Get.put(MainShellController());
    _connectivity = ConnectivityService();
  }

  late final ConnectivityService _connectivity;

  static const List<String> _tabTitles = <String>[
    'Home',
    'Reels',
    'Chat',
    'Profile',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainShellController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('OptiZenqor • ${_tabTitles[controller.index]}'),
            actions: <Widget>[
              if (controller.index == 0)
                IconButton(
                  onPressed: () => _openCreateScreen(context),
                  icon: const Icon(Icons.add_box_outlined),
                  tooltip: 'Create',
                ),
              IconButton(
                onPressed: () => Get.toNamed(RouteNames.searchDiscovery),
                icon: const Icon(Icons.search_rounded),
              ),
              IconButton(
                onPressed: () => Get.toNamed(RouteNames.notifications),
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'Notifications',
              ),
            ],
          ),
          drawer: Drawer(
            child: SafeArea(
              child: ListView(
                children: <Widget>[
                  const ListTile(
                    title: Text('Feature Hub'),
                    subtitle: Text('Quick access to core modules'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.groups_rounded),
                    title: const Text('Communities'),
                    onTap: () => Get.toNamed(RouteNames.communities),
                  ),
                  ListTile(
                    leading: const Icon(Icons.storefront_rounded),
                    title: const Text('Marketplace'),
                    onTap: () => Get.toNamed(RouteNames.marketplace),
                  ),
                  ListTile(
                    leading: const Icon(Icons.insights_rounded),
                    title: const Text('Creator Dashboard'),
                    onTap: () => Get.toNamed(RouteNames.creatorDashboard),
                  ),
                  ListTile(
                    leading: const Icon(Icons.workspace_premium_rounded),
                    title: const Text('Premium Plans'),
                    onTap: () => Get.toNamed(RouteNames.premium),
                  ),
                  ListTile(
                    leading: const Icon(Icons.drafts_rounded),
                    title: const Text('Drafts & Scheduling'),
                    onTap: () => Get.toNamed(RouteNames.draftsScheduling),
                  ),
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_rounded),
                    title: const Text('Upload Manager'),
                    onTap: () => Get.toNamed(RouteNames.uploadManager),
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              AnimatedBuilder(
                animation: _connectivity,
                builder: (_, __) {
                  if (_connectivity.isOnline) {
                    return const SizedBox.shrink();
                  }
                  return MaterialBanner(
                    content: const Text('You are offline. Some actions may fail.'),
                    leading: const Icon(Icons.wifi_off_rounded),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          await _connectivity.retryFailedAction((_) async {});
                        },
                        child: const Text('Retry'),
                      ),
                      TextButton(
                        onPressed: () => _connectivity.setOnline(true),
                        child: const Text('Go online'),
                      ),
                    ],
                  );
                },
              ),
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey<int>(controller.index),
                  child: _buildCurrentTab(controller.index),
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.index,
            onDestinationSelected: controller.onTabChanged,
            destinations: const <NavigationDestination>[
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

  Future<void> _openCreateScreen(BuildContext context) async {
    final CreatePostResult? result = await Navigator.of(context).push<CreatePostResult>(
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

  Widget _buildCurrentTab(int index) {
    switch (index) {
      case 0:
        return HomeFeedScreen();
      case 1:
        return ReelsScreen();
      case 2:
        return ChatScreen();
      case 3:
        return UserProfileScreen();
      case 4:
        return const SettingsScreen(showAppBar: false);
      default:
        return HomeFeedScreen();
    }
  }
}
