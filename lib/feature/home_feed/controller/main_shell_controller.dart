import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models/user_model.dart';
import '../../../core/enums/user_role.dart';
import '../../../app_route/route_names.dart';
import '../../auth/repository/auth_repository.dart';
import '../model/main_shell_destination_model.dart';
import '../model/main_shell_drawer_section_model.dart';

class MainShellController extends Cubit<int> {
  MainShellController({
    AuthRepository? authRepository,
    Object? arguments,
  }) : _authRepository = authRepository ?? AuthRepository(),
       super(0) {
    syncArguments(arguments);
    _hydrateCurrentUser();
  }

  int index = 0;
  bool isSigningOut = false;

  final AuthRepository _authRepository;
  Object? _lastArguments;

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

  UserModel currentUser = _guestUser;

  static const UserModel _guestUser = UserModel(
    id: '',
    name: 'Guest',
    username: 'guest',
    avatar: 'https://placehold.co/120x120',
    bio: '',
    role: UserRole.guest,
    followers: 0,
    following: 0,
  );


  String get currentTitle => destinations[index].title;

  bool get showCreateAction => index == 0;

  void syncArguments(Object? arguments) {
    if (identical(_lastArguments, arguments)) {
      return;
    }
    _lastArguments = arguments;
    if (arguments is Map && arguments['tabIndex'] is int) {
      final int tabIndex = arguments['tabIndex'] as int;
      if (tabIndex >= 0 && tabIndex < destinations.length && tabIndex != index) {
        index = tabIndex;
        emit(index);
      }
    }
  }

  Future<void> _hydrateCurrentUser() async {
    try {
      final UserModel? sessionUser = await _authRepository.currentUser();
      if (sessionUser == null) {
        return;
      }
      currentUser = sessionUser;
      emit(index);
    } catch (error, stackTrace) {
      debugPrint('[MainShellController] Failed to load current user: $error');
      debugPrint('$stackTrace');
    }
  }

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
    emit(index);
  }

  Future<void> logout() async {
    if (isSigningOut) {
      return;
    }
    isSigningOut = true;
    emit(index);
    try {
      await _authRepository.logout();
      // Navigation is handled by the shell screen listener.
      emit(index);
    } catch (error, stackTrace) {
      debugPrint('[MainShellController] Logout failed: $error');
      debugPrint('$stackTrace');
      rethrow;
    } finally {
      isSigningOut = false;
      emit(index);
    }
  }
}

