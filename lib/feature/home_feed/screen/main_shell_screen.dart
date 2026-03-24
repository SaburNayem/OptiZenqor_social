import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/enums/user_role.dart';
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

  final List<Widget> _tabs = [
    HomeFeedScreen(),
    ReelsScreen(),
    ChatScreen(),
    UserProfileScreen(),
    const SettingsScreen(showAppBar: false),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = MockData.users.first;

    return GetBuilder<MainShellController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('OptiZenqor - ${_tabTitles[controller.index]}'),
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
                  UserAccountsDrawerHeader(
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(currentUser.avatar),
                    ),
                    accountName: Text(currentUser.name),
                    accountEmail: Text('@${currentUser.username}'),
                    otherAccountsPictures: const [
                      CircleAvatar(
                        child: Icon(Icons.keyboard_arrow_right_rounded),
                      ),
                    ],
                    onDetailsPressed: () => Get.toNamed(
                      RouteNames.userProfile,
                      parameters: {'id': currentUser.id},
                    ),
                  ),
                  const _DrawerSectionHeader(
                    title: 'Create',
                    subtitle: 'Quick create actions',
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_box_outlined),
                    title: const Text('New post'),
                    onTap: () {
                      Navigator.pop(context);
                      _openCreateScreen(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.drafts_rounded),
                    title: const Text('Drafts'),
                    onTap: () => Get.toNamed(RouteNames.drafts),
                  ),
                  ListTile(
                    leading: const Icon(Icons.schedule_rounded),
                    title: const Text('Scheduling'),
                    onTap: () => Get.toNamed(RouteNames.scheduling),
                  ),
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_rounded),
                    title: const Text('Upload manager'),
                    onTap: () => Get.toNamed(RouteNames.uploadManager),
                  ),
                  const _DrawerSectionHeader(
                    title: 'Discover',
                    subtitle: 'Communities and marketplace',
                  ),
                  ListTile(
                    leading: const Icon(Icons.groups_rounded),
                    title: const Text('Communities'),
                    onTap: () => Get.toNamed(RouteNames.communities),
                  ),
                  ListTile(
                    leading: const Icon(Icons.group_work_outlined),
                    title: const Text('Groups'),
                    onTap: () => Get.toNamed(RouteNames.groups),
                  ),
                  ListTile(
                    leading: const Icon(Icons.pages_outlined),
                    title: const Text('Pages'),
                    onTap: () => Get.toNamed(RouteNames.pages),
                  ),
                  ListTile(
                    leading: const Icon(Icons.storefront_rounded),
                    title: const Text('Marketplace'),
                    onTap: () => Get.toNamed(RouteNames.marketplace),
                  ),
                  const _DrawerSectionHeader(
                    title: 'Growth',
                    subtitle: 'Creator and professional tools',
                  ),
                  if (currentUser.role != UserRole.user &&
                      currentUser.role != UserRole.guest)
                    ListTile(
                      leading: const Icon(Icons.insights_rounded),
                      title: const Text('Creator dashboard'),
                      onTap: () => Get.toNamed(RouteNames.creatorDashboard),
                    ),
                  if (currentUser.role != UserRole.user &&
                      currentUser.role != UserRole.guest)
                    ListTile(
                      leading: const Icon(Icons.workspace_premium_rounded),
                      title: const Text('Premium plans'),
                      onTap: () => Get.toNamed(RouteNames.premium),
                    ),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: const Text('Wallet & payments'),
                    onTap: () => Get.toNamed(RouteNames.walletPayments),
                  ),
                  const _DrawerSectionHeader(
                    title: 'Library',
                    subtitle: 'Saved content and history',
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark_outline_rounded),
                    title: const Text('Saved posts'),
                    onTap: () => Get.toNamed(RouteNames.bookmarks),
                  ),
                  ListTile(
                    leading: const Icon(Icons.archive_outlined),
                    title: const Text('Archived posts'),
                    onTap: () => Get.toNamed(RouteNames.archiveCenter),
                  ),
                  ListTile(
                    leading: const Icon(Icons.event_outlined),
                    title: const Text('Events'),
                    onTap: () => Get.toNamed(RouteNames.events),
                  ),
                  ListTile(
                    leading: const Icon(Icons.live_tv_outlined),
                    title: const Text('Live stream'),
                    onTap: () => Get.toNamed(RouteNames.liveStream),
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              AnimatedBuilder(
                animation: _connectivity,
                builder: (_, _) {
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
                child: IndexedStack(
                  index: controller.index,
                  children: _tabs,
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
    final CreatePostResult? result =
        await Get.to<CreatePostResult>(() => const CreatePostScreen());
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Post created')));
    }
  }
}

class _DrawerSectionHeader extends StatelessWidget {
  const _DrawerSectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      subtitle: Text(subtitle),
    );
  }
}
