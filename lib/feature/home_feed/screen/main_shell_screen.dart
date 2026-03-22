import 'package:flutter/material.dart';

import '../../../route/route_names.dart';
import '../../chat/screen/chat_screen.dart';
import '../../notifications/screen/notifications_screen.dart';
import '../../reels_short_video/screen/reels_screen.dart';
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

  late final List<Widget> _tabs = const [
    HomeFeedScreen(),
    ReelsScreen(),
    NotificationsScreen(),
    ChatScreen(),
    UserProfileScreen(),
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
            title: const Text('OptiZenqor Social'),
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context).pushNamed(RouteNames.searchDiscovery),
                icon: const Icon(Icons.search_rounded),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pushNamed(RouteNames.settings),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          body: IndexedStack(index: _controller.index, children: _tabs),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Create'),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _controller.index,
            onDestinationSelected: _controller.onTabChanged,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.play_circle_outline), label: 'Reels'),
              NavigationDestination(icon: Icon(Icons.notifications_none), label: 'Alerts'),
              NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
              NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
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
}
