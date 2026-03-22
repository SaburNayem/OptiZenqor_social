import 'package:flutter/material.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/enums/view_state.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/post_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../stories/widget/story_ring_list.dart';
import '../controller/home_feed_controller.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  late final HomeFeedController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeFeedController();
    _controller.loadInitial();
  }

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
        if (_controller.state == ViewState.loading) {
          return const AppLoader(label: 'Preparing your personalized feed');
        }
        if (_controller.state == ViewState.error) {
          return ErrorStateView(onRetry: _controller.loadInitial, message: 'Unable to load feed');
        }
        if (_controller.state == ViewState.empty) {
          return const EmptyStateView(
            title: 'Feed is quiet',
            message: 'Follow more people and communities to personalize this.',
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.refresh,
          child: ListView(
            padding: AppDimensions.pagePadding,
            children: [
              const SectionHeader(title: 'Stories'),
              const SizedBox(height: 10),
              StoryRingList(stories: _controller.stories, users: MockData.users),
              const SizedBox(height: 16),
              const SectionHeader(title: 'For You'),
              const SizedBox(height: 8),
              ..._controller.posts.map((post) {
                final user = MockData.users
                    .where((item) => item.id == post.authorId)
                    .firstOrNull;
                if (user == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PostCard(post: post, author: user),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
