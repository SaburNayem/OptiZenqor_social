import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/common_widget/empty_state_view.dart';
import '../../../core/common_widget/post_card.dart';
import '../../../core/navigation/app_get.dart';
import '../../bookmarks/controller/bookmarks_controller.dart';
import '../../bookmarks/widget/save_post_collection_sheet.dart';
import '../../post_detail/screen/post_detail_screen.dart';
import '../../share_repost_system/widget/share_post_action_sheet.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../controller/home_feed_controller.dart';

class HiddenPostsScreen extends StatelessWidget {
  const HiddenPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeFeedController, int>(
      builder: (context, _) {
        final controller = context.read<HomeFeedController>();
        final hiddenPosts = controller.hiddenPosts;

        return BlocBuilder<BookmarksController, BookmarksState>(
          builder: (context, _) {
            final BookmarksController bookmarksController = context
                .read<BookmarksController>();
            return Scaffold(
              appBar: AppBar(title: const Text('Hidden posts')),
              body: hiddenPosts.isEmpty
                  ? const EmptyStateView(
                      title: 'No hidden posts',
                      message: 'Posts you hide from the feed will appear here.',
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: hiddenPosts
                          .map((post) {
                            final user = post.author;
                            if (user == null) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                PostCard(
                                  post: post,
                                  author: user,
                                  likeCount: controller.displayLikeCount(post),
                                  isLiked: controller.isLiked(post.id),
                                  isBookmarked: bookmarksController.isSaved(
                                    post.id,
                                  ),
                                  onTap: () => _openPostDetail(context, post),
                                  onAuthorTap: () =>
                                      _openOtherProfile(context, user.id),
                                  onLikeTap: () => controller.likePost(post.id),
                                  onCommentTap: () =>
                                      _openPostDetail(context, post),
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
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        try {
                                          await controller.unhidePost(post.id);
                                          if (!context.mounted) {
                                            return;
                                          }
                                          _showFeedback(
                                            context,
                                            'Post restored to feed',
                                          );
                                        } catch (error) {
                                          if (!context.mounted) {
                                            return;
                                          }
                                          _showFeedback(
                                            context,
                                            error.toString().replaceFirst(
                                              'Exception: ',
                                              '',
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.visibility_rounded,
                                      ),
                                      label: const Text('Unhide post'),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          })
                          .toList(growable: false),
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

  void _showFeedback(BuildContext context, String message) {
    AppGet.snackbar('Hidden posts', message);
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
}
