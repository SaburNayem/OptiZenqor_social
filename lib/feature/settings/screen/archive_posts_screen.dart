import 'package:flutter/material.dart';

import '../../../core/common_widget/empty_state_view.dart';
import '../../../core/common_widget/post_card.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../post_detail/screen/post_detail_screen.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../repository/archive_repository.dart';

class ArchivePostsScreen extends StatelessWidget {
  const ArchivePostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArchiveRepository repository = ArchiveRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Archived posts')),
      body: FutureBuilder<List<PostModel>>(
        future: repository.archivedPosts(),
        builder: (BuildContext context, AsyncSnapshot<List<PostModel>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<PostModel> posts = snapshot.data ?? const <PostModel>[];
          if (posts.isEmpty) {
            return const EmptyStateView(
              title: 'No archived posts',
              message: 'Archived posts from backend will appear here.',
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: posts.map((PostModel post) {
              final UserModel? author = post.author;
              if (author == null) {
                return const SizedBox.shrink();
              }
              return PostCard(
                post: post,
                author: author,
                likeCount: post.likes,
                isLiked: false,
                isBookmarked: false,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PostDetailScreen(postId: post.id),
                  ),
                ),
                onAuthorTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => UserProfileScreen(userId: author.id),
                  ),
                ),
                onLikeTap: () {},
                onCommentTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PostDetailScreen(postId: post.id),
                  ),
                ),
              );
            }).toList(growable: false),
          );
        },
      ),
    );
  }
}
