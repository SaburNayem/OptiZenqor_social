import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/community_group_model.dart';
import '../helpers/community_group_actions.dart';
import '../helpers/community_group_customize_sheet.dart';
import '../widgets/community_group_detail_widgets.dart';
import '../widgets/community_group_header.dart';
import '../widgets/community_group_tabs.dart';
import '../cubit/community_group_cubit.dart';
import '../cubit/community_group_state.dart';

class CommunityGroupScreen extends StatelessWidget {
  const CommunityGroupScreen({required this.group, super.key});

  final CommunityGroupModel group;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityGroupCubit(group: group),
      child: const _CommunityGroupView(),
    );
  }
}

class _CommunityGroupView extends StatelessWidget {
  const _CommunityGroupView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityGroupCubit, CommunityGroupState>(
      builder: (context, state) {
        final cubit = context.read<CommunityGroupCubit>();
        return DefaultTabController(
          length: 6,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                Navigator.of(context).pop(state.group);
              }
            },
            child: Scaffold(
              body: Stack(
                children: [
                  NestedScrollView(
                    headerSliverBuilder: (context, innerScrolled) => [
                      SliverAppBar(
                        pinned: true,
                        expandedHeight: 336,
                        title: Text(state.group.name),
                        actions: [
                          IconButton(
                            onPressed: () =>
                                CommunityGroupActions.showSearchInsideGroup(
                                  context,
                                ),
                            icon: const Icon(Icons.search_rounded),
                          ),
                          IconButton(
                            onPressed: () =>
                                CommunityGroupActions.showMoreMenu(context),
                            icon: const Icon(Icons.more_horiz_rounded),
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: CommunityGroupHeader(
                            group: state.group,
                            onJoin: cubit.toggleJoin,
                            onInvite: () =>
                                CommunityGroupActions.showInviteOptions(
                                  context,
                                ),
                            onMore: () =>
                                CommunityGroupActions.showMoreMenu(context),
                          ),
                        ),
                      ),
                    ],
                    body: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                        children: [
                          const Material(
                            color: Colors.white,
                            child: TabBar(
                              isScrollable: true,
                              labelPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              tabs: [
                                Tab(text: 'Home'),
                                Tab(text: 'Posts'),
                                Tab(text: 'Media'),
                                Tab(text: 'Events'),
                                Tab(text: 'Members'),
                                Tab(text: 'About'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                CommunityHomeTab(controller: cubit),
                                CommunityPostsTab(controller: cubit),
                                CommunityMediaTab(controller: cubit),
                                CommunityEventsTab(controller: cubit),
                                CommunityMembersTab(controller: cubit),
                                CommunityAboutTab(controller: cubit),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: CommunityBottomBar(
                      notificationsEnabled: state.notificationsEnabled,
                      onCreate: () =>
                          CommunityGroupActions.showCreatePostSheet(context),
                      onInvite: () =>
                          CommunityGroupActions.showInviteOptions(context),
                      onNotify: cubit.toggleNotificationBell,
                      onCustomize: () =>
                          showCommunityGroupCustomizeSheet(context, cubit),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
