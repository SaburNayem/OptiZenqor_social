import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/user_model.dart';
import '../../../core/enums/user_role.dart';
import '../../../route/route_names.dart';
import '../../auth/repository/auth_repository.dart';
import '../model/main_shell_destination_model.dart';
import '../model/main_shell_drawer_section_model.dart';

class MainShellController extends GetxController {
  MainShellController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  int index = 0;
  bool isSigningOut = false;

  final AuthRepository _authRepository;

  final List<MainShellDestinationModel> destinations =
      const <MainShellDestinationModel>[
        MainShellDestinationModel(
          label: 'Home',
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          title: 'Home',
        ),
        MainShellDestinationModel(
          label: 'Reels',
          icon: Icons.play_circle_outline,
          activeIcon: Icons.play_circle_rounded,
          title: 'Reels',
        ),
        MainShellDestinationModel(
          label: 'Create',
          icon: Icons.add_circle_outline,
          activeIcon: Icons.add_circle,
          title: 'Create',
        ),
        MainShellDestinationModel(
          label: 'Chat',
          icon: Icons.chat_bubble_outline,
          activeIcon: Icons.chat_bubble,
          title: 'Chat',
        ),
        MainShellDestinationModel(
          label: 'Profile',
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          title: 'Profile',
        ),
      ];

  late final UserModel currentUser;

  @override
  void onInit() {
    super.onInit();
    currentUser = MockData.users.first;
  }

  String get currentTitle => destinations[index].title;

  bool get showCreateAction => index == 0;

  List<MainShellDrawerSectionModel> get drawerSections {
    return <MainShellDrawerSectionModel>[
      const MainShellDrawerSectionModel(
        title: 'Create & Manage',
        subtitle: 'Publishing tools and saved workspaces.',
        items: <MainShellDrawerItemModel>[
          MainShellDrawerItemModel(
            title: 'Drafts',
            icon: Icons.drafts_rounded,
            routeName: RouteNames.drafts,
          ),
          MainShellDrawerItemModel(
            title: 'Scheduling',
            icon: Icons.schedule_rounded,
            routeName: RouteNames.scheduling,
          ),
          MainShellDrawerItemModel(
            title: 'Upload Manager',
            icon: Icons.cloud_upload_rounded,
            routeName: RouteNames.uploadManager,
          ),
          MainShellDrawerItemModel(
            title: 'Saved Posts',
            icon: Icons.bookmark_outline_rounded,
            routeName: RouteNames.bookmarks,
          ),
          MainShellDrawerItemModel(
            title: 'Archived Posts',
            icon: Icons.archive_outlined,
            routeName: RouteNames.archiveCenter,
          ),
        ],
      ),
      const MainShellDrawerSectionModel(
        title: 'Discover',
        subtitle: 'Explore communities, pages, and live surfaces.',
        items: <MainShellDrawerItemModel>[
          MainShellDrawerItemModel(
            title: 'Communities',
            icon: Icons.groups_rounded,
            routeName: RouteNames.communities,
          ),
          MainShellDrawerItemModel(
            title: 'Groups',
            icon: Icons.group_work_outlined,
            routeName: RouteNames.groups,
          ),
          MainShellDrawerItemModel(
            title: 'Pages',
            icon: Icons.pages_outlined,
            routeName: RouteNames.pages,
          ),
          MainShellDrawerItemModel(
            title: 'Marketplace',
            icon: Icons.storefront_rounded,
            routeName: RouteNames.marketplace,
          ),
          MainShellDrawerItemModel(
            title: 'Events',
            icon: Icons.event_outlined,
            routeName: RouteNames.events,
          ),
          MainShellDrawerItemModel(
            title: 'Live Stream',
            icon: Icons.live_tv_outlined,
            routeName: RouteNames.liveStream,
          ),
        ],
      ),
      if (currentUser.role == UserRole.creator ||
          currentUser.role == UserRole.business ||
          currentUser.role == UserRole.seller ||
          currentUser.role == UserRole.recruiter)
        MainShellDrawerSectionModel(
          title: 'Professional',
          subtitle: 'Role-aware tools for growth and monetization.',
          items: <MainShellDrawerItemModel>[
            if (currentUser.role == UserRole.creator)
              const MainShellDrawerItemModel(
                title: 'Creator Dashboard',
                icon: Icons.insights_rounded,
                routeName: RouteNames.creatorDashboard,
              ),
            const MainShellDrawerItemModel(
              title: 'Premium Plans',
              icon: Icons.workspace_premium_rounded,
              routeName: RouteNames.premium,
            ),
            const MainShellDrawerItemModel(
              title: 'Wallet',
              icon: Icons.account_balance_wallet_outlined,
              routeName: RouteNames.walletPayments,
            ),
            const MainShellDrawerItemModel(
              title: 'Subscriptions',
              icon: Icons.subscriptions_outlined,
              routeName: RouteNames.subscriptions,
            ),
          ],
        ),
    ];
  }

  void onTabChanged(int newIndex) {
    if (newIndex == 2) {
      // Create tab - handle externally if needed or just switch
      // Often "Create" is a modal but here it's a tab index.
    }
    index = newIndex;
    update();
  }

  Future<void> logout() async {
    if (isSigningOut) {
      return;
    }
    isSigningOut = true;
    update();
    try {
      await _authRepository.logout();
      Get.offAllNamed(RouteNames.login);
    } catch (error, stackTrace) {
      debugPrint('[MainShellController] Logout failed: $error');
      debugPrint('$stackTrace');
      rethrow;
    } finally {
      isSigningOut = false;
      update();
    }
  }
}
