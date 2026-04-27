import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/common_widget/empty_state_view.dart';
import '../../../core/common_widget/error_state_view.dart';
import '../../../core/common_widget/post_card.dart';
import '../../../core/navigation/app_get.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../bookmarks/controller/bookmarks_controller.dart';
import '../../bookmarks/widget/save_post_collection_sheet.dart';
import '../../post_detail/screen/post_detail_screen.dart';
import '../../share_repost_system/widget/share_post_action_sheet.dart';
import '../../stories/widget/story_ring_list.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../controller/home_feed_controller.dart';
import '../controller/main_shell_controller.dart';

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
        final List<PostModel> visiblePosts = controller.visiblePosts;
        final bool hasVisibleContent =
            controller.stories.isNotEmpty || visiblePosts.isNotEmpty;
        if (controller.isLoading) {
          return const _FeedShimmer();
        }
        if (controller.hasError && !hasVisibleContent) {
          return ErrorStateView(
            onRetry: controller.loadInitial,
            message: controller.loadState.errorMessage ?? 'Unable to load feed',
          );
        }

        return BlocBuilder<BookmarksController, BookmarksState>(
          builder: (context, _) {
            final BookmarksController bookmarksController = context
                .read<BookmarksController>();
            final UserModel? currentUser =
                context.read<MainShellController>().currentUser.id.isNotEmpty
                ? context.read<MainShellController>().currentUser
                : null;
            final List<UserModel> storyUsers = <UserModel>[
              if (currentUser != null) currentUser,
              ...visiblePosts
                  .map((PostModel post) => post.author)
                  .whereType<UserModel>(),
              ...controller.stories
                  .map((StoryModel story) => story.author)
                  .whereType<UserModel>(),
            ];
            final Map<String, UserModel> storyUsersById = <String, UserModel>{
              for (final UserModel user in storyUsers) user.id: user,
            };
            return RefreshIndicator(
              onRefresh: controller.refreshFeed,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  const SizedBox(height: 8),
                  StoryRingList(
                    stories: controller.stories,
                    currentUser: currentUser,
                    users: storyUsersById.values.toList(growable: false),
                    onStoryAdded: (List<StoryModel> createdStories) async {
                      await controller.createStories(createdStories);
                      if (!context.mounted || !controller.hasError) {
                        return;
                      }
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              controller.loadState.errorMessage ??
                                  'Unable to create story right now.',
                            ),
                          ),
                        );
                    },
                    onStoriesSeen: (List<String> storyIds) {
                      controller.markStoriesSeen(storyIds);
                    },
                    onStoryDeleted: (String storyId) async {
                      await controller.deleteStory(storyId);
                    },
                  ),
                  const Divider(height: 32, thickness: 0.5),
                  if (visiblePosts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: EmptyStateView(
                        title: 'Feed is quiet',
                        message:
                            'No posts yet, but stories are still available above.',
                      ),
                    )
                  else
                    ...visiblePosts.map((post) {
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
                        onTap: () => _openPostDetail(context, post),
                        onAuthorTap: () => _openOtherProfile(context, user.id),
                        onMoreTap: () => _showPostActions(context, post.id),
                        onLikeTap: () => controller.likePost(post.id),
                        onCommentTap: () => _openPostDetail(context, post),
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
    final HomeFeedController controller = context.read<HomeFeedController>();
    PostModel? selectedPost;
    for (final PostModel post in controller.posts) {
      if (post.id == postId) {
        selectedPost = post;
        break;
      }
    }
    final bool isOwnPost =
        selectedPost != null && controller.isOwnPost(selectedPost);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            if (isOwnPost && selectedPost != null) ...[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit post'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _editPostCaption(context, controller, selectedPost!);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Delete post'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _deletePost(context, controller, selectedPost!);
                },
              ),
            ] else
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

  void _openPostDetail(BuildContext context, PostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PostDetailScreen(postId: post.id, initialPost: post),
      ),
    );
  }

  Future<void> _editPostCaption(
    BuildContext context,
    HomeFeedController controller,
    PostModel post,
  ) async {
    final TextEditingController textController = TextEditingController(
      text: post.caption,
    );
    final String? nextCaption = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit post'),
          content: TextField(
            controller: textController,
            maxLines: 5,
            minLines: 3,
            decoration: const InputDecoration(hintText: 'Write something...'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(textController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    textController.dispose();
    if (nextCaption == null || nextCaption.trim().isEmpty || !context.mounted) {
      return;
    }
    try {
      await controller.editPostCaption(postId: post.id, caption: nextCaption);
      if (!context.mounted) {
        return;
      }
      _showFeedback(context, 'Post updated');
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _showFeedback(context, error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _deletePost(
    BuildContext context,
    HomeFeedController controller,
    PostModel post,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete post?'),
          content: const Text('This post will be removed from your feed.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      await controller.deleteOwnedPost(post.id);
      if (!context.mounted) {
        return;
      }
      _showFeedback(context, 'Post deleted');
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _showFeedback(context, error.toString().replaceFirst('Exception: ', ''));
    }
  }
}

class _FeedShimmer extends StatelessWidget {
  const _FeedShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const [
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ShimmerBox(height: 64, width: 64, radius: 32),
                SizedBox(width: 12),
                ShimmerBox(height: 64, width: 64, radius: 32),
                SizedBox(width: 12),
                ShimmerBox(height: 64, width: 64, radius: 32),
                SizedBox(width: 12),
                ShimmerBox(height: 64, width: 64, radius: 32),
              ],
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ShimmerBox(height: 36, width: 36, radius: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: 14, width: 120),
                      SizedBox(height: 8),
                      ShimmerBox(height: 12, width: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: ShimmerBox(height: 320, radius: 20),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerBox(height: 14, width: 90),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerBox(height: 12),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ShimmerBox(height: 36, width: 36, radius: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: 14, width: 140),
                      SizedBox(height: 8),
                      ShimmerBox(height: 12, width: 90),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: ShimmerBox(height: 320, radius: 20),
          ),
        ],
      ),
    );
  }
}
