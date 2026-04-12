import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/mock/mock_data.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/post_card.dart';
import '../../post_detail/screen/post_detail_screen.dart';
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
                        final user = MockData.users
                            .where((item) => item.id == post.authorId)
                            .firstOrNull;
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
                              onTap: () => _openPostDetail(context, post.id),
                              onAuthorTap: () =>
                                  _openOtherProfile(context, user.id),
                              onLikeTap: () => controller.likePost(post.id),
                              onCommentTap: () =>
                                  _openPostDetail(context, post.id),
                              onBookmarkTap: () =>
                                  _showFeedback(context, 'Saved to bookmarks'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    controller.unhidePost(post.id);
                                    _showFeedback(
                                      context,
                                      'Post restored to feed',
                                    );
                                  },
                                  icon: const Icon(Icons.visibility_rounded),
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
      MaterialPageRoute<void>(builder: (_) => PostDetailScreen(postId: postId)),
    );
  }
}
