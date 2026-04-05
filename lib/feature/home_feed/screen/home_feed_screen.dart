import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/mock/mock_data.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/post_card.dart';
import '../../post_detail/screen/post_detail_screen.dart';
import '../../stories/widget/story_ring_list.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../controller/home_feed_controller.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final ScrollPosition position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<HomeFeedController>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeFeedController, int>(
      builder: (context, _) {
        final HomeFeedController controller = context.read<HomeFeedController>();
        if (controller.isLoading) {
          return const AppLoader(label: 'Preparing your personalized feed');
        }
        if (controller.hasError) {
          return ErrorStateView(
            onRetry: controller.loadInitial,
            message: controller.loadState.errorMessage ?? 'Unable to load feed',
          );
        }
        if (controller.loadState.isEmpty) {
          return const EmptyStateView(
            title: 'Feed is quiet',
            message: 'Follow more people and communities to personalize this.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshFeed,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const SizedBox(height: 8),
              StoryRingList(
                stories: controller.stories,
                users: MockData.users,
                onStoryAdded: controller.addLocalStories,
              ),
              const Divider(height: 32, thickness: 0.5),
              ...controller.visiblePosts.map((post) {
                final user = MockData.users
                    .where((item) => item.id == post.authorId)
                    .firstOrNull;
                if (user == null) {
                  return const SizedBox.shrink();
                }
                return PostCard(
                  post: post,
                  author: user,
                  likeCount: controller.displayLikeCount(post),
                  isLiked: controller.isLiked(post.id),
                  onTap: () => _openPostDetail(context, post.id),
                  onAuthorTap: () => _openOtherProfile(context, user.id),
                  onMoreTap: () => _showPostActions(context, post.id),
                  onLikeTap: () => controller.likePost(post.id),
                  onCommentTap: () => _openPostDetail(context, post.id),
                  onBookmarkTap: () => _showFeedback(context, 'Saved to bookmarks'),
                );
              }),
              if (controller.isLoadingMore) ...[
                const SizedBox(height: 8),
                const Center(child: CircularProgressIndicator()),
              ],
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
}
