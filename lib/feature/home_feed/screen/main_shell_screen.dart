import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../route/route_names.dart';
import '../../chat/screen/chat_screen.dart';
import '../../reels_short_video/screen/reels_screen.dart';
import '../../settings/screen/settings_screen.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../common/main_shell_drawer_section.dart';
import '../controller/main_shell_controller.dart';
import 'create_post_screen.dart';
import 'home_feed_screen.dart';

class MainShellScreen extends StatelessWidget {
  MainShellScreen({super.key}) {
    Get.put(MainShellController());
    _connectivity = ConnectivityService();
  }

  late final ConnectivityService _connectivity;

  @override
  Widget build(BuildContext context) {
    final currentUser = MockData.users.first;
    final tabs = <Widget>[
      HomeFeedScreen(),
      ReelsScreen(),
      ChatScreen(),
      UserProfileScreen(),
      const SettingsScreen(showAppBar: false),
    ];

    return GetBuilder<MainShellController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('OptiZenqor • ${controller.currentTitle}'),
            actions: <Widget>[
              if (controller.showCreateAction)
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
                    margin: EdgeInsets.zero,
                    otherAccountsPictures: const <Widget>[
                      CircleAvatar(
                        child: Icon(Icons.keyboard_arrow_right_rounded),
                      ),
                    ],
                    onDetailsPressed: () => Get.toNamed(
                      RouteNames.userProfile,
                      parameters: <String, String>{'id': currentUser.id},
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_box_outlined),
                    title: const Text('New post'),
                    subtitle: const Text('Jump into the composer'),
                    onTap: () {
                      Navigator.pop(context);
                      _openCreateScreen(context);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Text('Feature Hub'),
                  ),
                  ...controller.drawerSections.map(
                    (section) => MainShellDrawerSection(
                      section: section,
                      onTap: (routeName) {
                        Get.back<void>();
                        Get.toNamed(routeName);
                      },
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
                    content: const Text('You are offline. Some actions may fail.'),
                    leading: const Icon(Icons.wifi_off_rounded),
                    actions: <Widget>[
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
                  children: tabs,
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.index,
            onDestinationSelected: controller.onTabChanged,
            destinations: controller.destinations
                .map(
                  (destination) => NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.activeIcon),
                    label: destination.label,
                  ),
                )
                .toList(growable: false),
          ),
        );
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
