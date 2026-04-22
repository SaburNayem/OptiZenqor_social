import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/service/connectivity_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../chat/screen/chat_screen.dart';
import '../../reels_short_video/screen/reels_screen.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../controller/home_feed_controller.dart';
import '../controller/main_shell_controller.dart';
import '../model/create_post_result_model.dart';
import '../widget/main_shell_bottom_nav_bar.dart';
import '../widget/main_shell_drawer.dart';
import '../widget/main_shell_home_app_bar.dart';
import 'create_post_screen.dart';
import 'home_feed_screen.dart';

class MainShellScreen extends StatelessWidget {
  MainShellScreen({super.key, this.arguments}) {
    _connectivity = ConnectivityService();
  }

  final Object? arguments;
  late final ConnectivityService _connectivity;

  @override
  Widget build(BuildContext context) {
    final MainShellController controller = context.read<MainShellController>();
    controller.syncArguments(arguments);

    return BlocBuilder<MainShellController, int>(
      builder: (context, _) {
        final tabs = <Widget>[
          HomeFeedScreen(),
          ReelsScreen(),
          const SizedBox.shrink(), // Placeholder for center FAB action
          ChatScreen(),
          const UserProfileScreen(),
        ];

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: controller.index == 0 ? const MainShellHomeAppBar() : null,
          drawer: MainShellDrawer(controller: controller),
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
                child: KeyedSubtree(
                  key: ValueKey<int>(controller.index),
                  child: tabs[controller.index],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openCreateScreen(context),
            backgroundColor: AppColors.hexFF26C6DA,
            shape: const CircleBorder(),
            elevation: 4,
            child: const Icon(Icons.add, color: AppColors.white, size: 32),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: MainShellBottomNavBar(
            selectedIndex: controller.index,
            onChanged: controller.onTabChanged,
          ),
        );
      },
    );
  }

  Future<void> _openCreateScreen(BuildContext context) async {
    final homeFeedController = context.read<HomeFeedController>();
    final CreatePostResult? result = await Navigator.of(context)
        .push<CreatePostResult>(
          MaterialPageRoute<CreatePostResult>(
            builder: (_) => CreatePostScreen(),
          ),
        );
    if (result != null && context.mounted) {
      await homeFeedController.createLocalPost(
        caption: result.caption,
        mediaPaths: result.mediaPaths,
        isVideo: result.isVideo,
        audience: result.audience,
        location: result.location,
        taggedPeople: result.taggedPeople,
        coAuthors: result.coAuthors,
        altText: result.altText,
        editHistory: result.editHistory,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Post created')));
    }
  }
}

