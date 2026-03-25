import 'package:flutter/material.dart';

import '../common_models/post_model.dart';
import '../common_models/user_model.dart';
import '../helpers/format_helper.dart';
import 'app_avatar.dart';
import 'inline_video_player.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    required this.post,
    required this.author,
    this.likeCount,
    this.isLiked = false,
    this.onTap,
    this.onAuthorTap,
    this.onMoreTap,
    this.onLikeTap,
    this.onCommentTap,
    this.onBookmarkTap,
    super.key,
  });

  final PostModel post;
  final UserModel author;
  final int? likeCount;
  final bool isLiked;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    AppAvatar(
                      imageUrl: author.avatar,
                      verified: author.verified,
                      radius: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: onAuthorTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author.name,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              FormatHelper.timeAgo(post.createdAt),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onMoreTap,
                      icon: const Icon(Icons.more_horiz, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Media
              if (post.media.isNotEmpty)
                Builder(
                  builder: (context) {
                    final media = post.media.first;
                    final lower = media.toLowerCase();
                    final isVideo = lower.endsWith('.mp4') ||
                        lower.endsWith('.mov') ||
                        lower.endsWith('.webm') ||
                        lower.endsWith('.m4v');
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 1, // Instagram-like square or 4:5
                        child: isVideo
                            ? InlineVideoPlayer(networkUrl: media, autoPlay: true)
                            : Image.network(media, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 12),
              // Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onLikeTap,
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                    ),
                    IconButton(
                      onPressed: onCommentTap,
                      icon: const Icon(Icons.chat_bubble_outline),
                    ),
                    IconButton(
                      onPressed: () {}, // Share action
                      icon: const Icon(Icons.share_outlined),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onBookmarkTap,
                      icon: const Icon(Icons.bookmark_border_rounded),
                    ),
                  ],
                ),
              ),
              // Likes and Caption
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${FormatHelper.formatCompactNumber(likeCount ?? post.likes)} likes',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '@${author.username} ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: post.caption),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (post.comments > 0)
                      InkWell(
                        onTap: onCommentTap,
                        child: Text(
                          'View all ${post.comments} comments',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
