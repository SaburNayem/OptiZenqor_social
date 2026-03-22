import 'package:flutter/material.dart';

import '../common_models/post_model.dart';
import '../common_models/user_model.dart';
import '../helpers/format_helper.dart';
import 'app_avatar.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    required this.post,
    required this.author,
    super.key,
  });

  final PostModel post;
  final UserModel author;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(
                  imageUrl: author.avatar,
                  verified: author.verified,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author.name, style: Theme.of(context).textTheme.titleSmall),
                      Text('@${author.username} • ${FormatHelper.timeAgo(post.createdAt)}'),
                    ],
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.caption),
            if (post.media.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(post.media.first, fit: BoxFit.cover),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _EngagementChip(icon: Icons.favorite_border, value: post.likes),
                const SizedBox(width: 8),
                _EngagementChip(icon: Icons.mode_comment_outlined, value: post.comments),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border_rounded)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EngagementChip extends StatelessWidget {
  const _EngagementChip({required this.icon, required this.value});

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(FormatHelper.formatCompactNumber(value)),
        ],
      ),
    );
  }
}
