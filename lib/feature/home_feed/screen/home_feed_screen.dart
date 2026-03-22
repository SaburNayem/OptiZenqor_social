import 'package:flutter/material.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/post_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../route/route_names.dart';
import '../../stories/widget/story_ring_list.dart';
import '../controller/home_feed_controller.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  late final HomeFeedController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = HomeFeedController();
    _controller.loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _controller.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isLoading) {
          return const AppLoader(label: 'Preparing your personalized feed');
        }
        if (_controller.hasError) {
          return ErrorStateView(
            onRetry: _controller.loadInitial,
            message: _controller.state.errorMessage ?? 'Unable to load feed',
          );
        }
        if (_controller.state.isEmpty) {
          return const EmptyStateView(
            title: 'Feed is quiet',
            message: 'Follow more people and communities to personalize this.',
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.refresh,
          child: ListView(
            controller: _scrollController,
            padding: AppDimensions.pagePadding,
            children: [
              const SectionHeader(title: 'Stories'),
              const SizedBox(height: 10),
              StoryRingList(stories: _controller.stories, users: MockData.users),
              const SizedBox(height: 16),
              _FeedTabSelector(
                activeTab: _controller.activeTab,
                onTabSelected: _controller.setTab,
              ),
              const SizedBox(height: 12),
              _SuggestionsStrip(controller: _controller),
              const SizedBox(height: 8),
              ..._controller.visiblePosts.map((post) {
                final user = MockData.users
                    .where((item) => item.id == post.authorId)
                    .firstOrNull;
                if (user == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PostCard(
                    post: post,
                    author: user,
                    likeCount: _controller.displayLikeCount(post),
                    isLiked: _controller.isLiked(post.id),
                    onTap: () => Navigator.of(context).pushNamed(RouteNames.postDetail),
                    onMoreTap: () => _showPostActions(context, post.id),
                    onLikeTap: () => _controller.likePost(post.id),
                    onCommentTap: () {
                      _showFeedback(context, 'Opening comments');
                      Navigator.of(context).pushNamed(RouteNames.postDetail);
                    },
                    onBookmarkTap: () => _showFeedback(context, 'Saved to bookmarks'),
                  ),
                );
              }),
              if (_controller.isLoadingMore) ...[
                const SizedBox(height: 8),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_controller.state.hasError && !_controller.isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: _controller.loadNextPage,
                    child: const Text('Retry loading more'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPostActions(BuildContext context, String postId) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('View Post Details'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(RouteNames.postDetail);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.of(context).pop();
                _showFeedback(context, 'Share flow for $postId');
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('Not Interested'),
              onTap: () {
                Navigator.of(context).pop();
                _controller.notInterested(postId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report'),
              onTap: () {
                Navigator.of(context).pop();
                _showFeedback(context, 'Report submitted');
              },
            ),
          ],
        );
      },
    );
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FeedTabSelector extends StatelessWidget {
  const _FeedTabSelector({
    required this.activeTab,
    required this.onTabSelected,
  });

  final FeedTab activeTab;
  final Future<void> Function(FeedTab) onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: FeedTab.values.map((FeedTab tab) {
        return ChoiceChip(
          label: Text(_labelForTab(tab)),
          selected: tab == activeTab,
          onSelected: (_) {
            onTabSelected(tab);
          },
        );
      }).toList(),
    );
  }

  String _labelForTab(FeedTab tab) {
    switch (tab) {
      case FeedTab.forYou:
        return 'For You';
      case FeedTab.following:
        return 'Following';
      case FeedTab.trending:
        return 'Trending';
    }
  }
}

class _SuggestionsStrip extends StatelessWidget {
  const _SuggestionsStrip({required this.controller});

  final HomeFeedController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...controller.suggestedUsers.map((String item) => _chip('User', item)),
          ...controller.suggestedGroups.map((String item) => _chip('Group', item)),
          ...controller.suggestedPages.map((String item) => _chip('Page', item)),
        ],
      ),
    );
  }

  Widget _chip(String type, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(label: Text('$type: $value')),
    );
  }
}
