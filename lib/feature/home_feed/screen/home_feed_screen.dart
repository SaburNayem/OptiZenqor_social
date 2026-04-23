import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/common_widget/app_loader.dart';
import '../../../core/common_widget/empty_state_view.dart';
import '../../../core/common_widget/error_state_view.dart';
import '../../../core/common_widget/post_card.dart';
import '../../../core/navigation/app_get.dart';
import '../../bookmarks/controller/bookmarks_controller.dart';
import '../../bookmarks/widget/save_post_collection_sheet.dart';
import '../../post_detail/screen/post_detail_screen.dart';
import '../../share_repost_system/widget/share_post_action_sheet.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<HomeFeedController>().restore();
    });
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
        final HomeFeedController controller = context
            .read<HomeFeedController>();
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

        return BlocBuilder<BookmarksController, BookmarksState>(
          builder: (context, _) {
            final BookmarksController bookmarksController =
                context.read<BookmarksController>();
            return RefreshIndicator(
              onRefresh: controller.refreshFeed,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  const SizedBox(height: 8),
                  if (controller.stories.isNotEmpty)
                    StoryRingList(
                      stories: controller.stories,
                      users: controller.visiblePosts
                          .map((PostModel post) => post.author)
                          .whereType<UserModel>()
                          .toList(growable: false),
                      onStoryAdded: controller.addLocalStories,
                    ),
                  const Divider(height: 32, thickness: 0.5),
                  ...controller.visiblePosts.map((post) {
                    final UserModel? user = post.author;
                    if (user == null) {
                      return const SizedBox.shrink();
                    }
                    return PostCard(
                      post: post,
                      author: user,
                      likeCount: controller.displayLikeCount(post),
                      isLiked: controller.isLiked(post.id),
                      isBookmarked: bookmarksController.isSaved(post.id),
                      onTap: () => _openPostDetail(context, post.id),
                      onAuthorTap: () => _openOtherProfile(context, user.id),
                      onMoreTap: () => _showPostActions(context, post.id),
                      onLikeTap: () => controller.likePost(post.id),
                      onCommentTap: () => _openPostDetail(context, post.id),
                      onShareTap: () => showSharePostActionSheet(
                        context: context,
                        post: post,
                        author: user,
                      ),
                      onBookmarkTap: () => _handleBookmarkTap(
                        context: context,
                        bookmarksController: bookmarksController,
                        post: post,
                        user: user,
                      ),
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
      },
    );
  }

  Future<void> _handleBookmarkTap({
    required BuildContext context,
    required BookmarksController bookmarksController,
    required PostModel post,
    required UserModel user,
  }) async {
    if (bookmarksController.isSaved(post.id)) {
      await bookmarksController.unsave(post.id);
      if (!context.mounted) {
        return;
      }
      _showFeedback(context, 'Removed from saved posts');
      return;
    }

    final String? destination = await showSavePostCollectionSheet(
      context: context,
      controller: bookmarksController,
      onSave: (collectionId) => bookmarksController.savePost(
        post: post,
        author: user,
        collectionId: collectionId,
      ),
    );
    if (destination == null || !context.mounted) {
      return;
    }
    _showFeedback(context, 'Saved to $destination');
  }

  Future<void> _showPostActions(BuildContext context, String postId) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        final controller = context.read<HomeFeedController>();
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
              leading: const Icon(Icons.hide_source_outlined),
              title: const Text('Hide post'),
              onTap: () {
                controller.notInterested(postId);
                Navigator.of(context).pop();
                _showFeedback(context, 'Post hidden from feed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.tune_rounded),
              title: const Text('Show less like this'),
              onTap: () async {
                await controller.showLessLikeThis(postId);
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pop();
                _showFeedback(context, 'We will show fewer similar posts');
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
    AppGet.snackbar('Feed', message);
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
      MaterialPageRoute<void>(builder: (_) => PostDetailScreen(postId: postId)),
    );
  }
}

