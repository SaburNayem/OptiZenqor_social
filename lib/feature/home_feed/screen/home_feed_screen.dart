import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/post_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../post_detail/screen/post_detail_screen.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../../stories/widget/story_ring_list.dart';
import '../controller/home_feed_controller.dart';
import 'create_post_screen.dart';

class HomeFeedScreen extends StatelessWidget {
  HomeFeedScreen({super.key}) {
    _controller.loadInitial();
    _scrollController.addListener(_onScroll);
  }

  final HomeFeedController _controller = Get.put(HomeFeedController());
  final ScrollController _scrollController = ScrollController();

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
    return GetBuilder<HomeFeedController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const AppLoader(label: 'Preparing your personalized feed');
        }
        if (controller.hasError) {
          return ErrorStateView(
            onRetry: controller.loadInitial,
            message: controller.state.errorMessage ?? 'Unable to load feed',
          );
        }
        if (controller.state.isEmpty) {
          return const EmptyStateView(
            title: 'Feed is quiet',
            message: 'Follow more people and communities to personalize this.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView(
            controller: _scrollController,
            padding: AppDimensions.pagePadding,
            children: [
              _QuickComposer(
                onCreateTap: () => _openCreatePostScreen(context),
              ),
              const SizedBox(height: 14),
              const SectionHeader(title: 'Stories'),
              const SizedBox(height: 10),
              StoryRingList(stories: controller.stories, users: MockData.users),
              const SizedBox(height: 16),
              _FeedTabSelector(
                activeTab: controller.activeTab,
                onTabSelected: controller.setTab,
              ),
              const SizedBox(height: 8),
              ...controller.visiblePosts.map((post) {
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
                    likeCount: controller.displayLikeCount(post),
                    isLiked: controller.isLiked(post.id),
                    onTap: () => _openPostDetail(context, post.id),
                    onAuthorTap: () => _openOtherProfile(context, user.id),
                    onMoreTap: () => _showPostActions(context, post.id),
                    onLikeTap: () => controller.likePost(post.id),
                    onCommentTap: () {
                      _openPostDetail(context, post.id);
                    },
                    onBookmarkTap: () => _showFeedback(context, 'Saved to bookmarks'),
                  ),
                );
              }),
              if (controller.isLoadingMore) ...[
                const SizedBox(height: 8),
                const Center(child: CircularProgressIndicator()),
              ],
              if (controller.state.hasError && !controller.isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: controller.loadNextPage,
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
                _openPostDetail(context, postId);
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

  void _openOtherProfile(BuildContext context, String userId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => UserProfileScreen(userId: userId),
      ),
    );
  }

  void _openPostDetail(BuildContext context, String postId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PostDetailScreen(postId: postId),
      ),
    );
  }

  Future<void> _openCreatePostScreen(BuildContext context) async {
    final result = await Navigator.of(context).push<CreatePostResult>(
      MaterialPageRoute<CreatePostResult>(
        builder: (_) => CreatePostScreen(),
      ),
    );

    if (result == null) {
      return;
    }

    await _controller.createLocalPost(
      caption: result.caption,
      mediaUrl: result.mediaUrl,
      isVideo: result.isVideo,
    );

    _showFeedback(context, 'Post created');
  }
}

class _QuickComposer extends StatelessWidget {
  const _QuickComposer({required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: onCreateTap,
              icon: const Icon(Icons.movie_filter_outlined),
              tooltip: 'Create reel',
            ),
            Expanded(
              child: InkWell(
                onTap: onCreateTap,
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Share what you are thinking...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              tooltip: 'Add photo',
            ),
            IconButton(
              onPressed: onCreateTap,
              icon: const Icon(Icons.videocam_outlined),
              tooltip: 'Add video',
            ),
          ],
        ),
      ),
    );
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
