import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../model/post_comment_model.dart';

class PostCommentTile extends StatelessWidget {
  const PostCommentTile({
    super.key,
    required this.comment,
    this.depth = 0,
    this.onLikeTap,
    this.onReplyTap,
  });

  final PostCommentModel comment;
  final int depth;
  final VoidCallback? onLikeTap;
  final VoidCallback? onReplyTap;

  @override
  Widget build(BuildContext context) {
    final String avatarUrl = _avatarFor(comment);

    return Padding(
      padding: EdgeInsets.only(
        left: 16 + (_effectiveDepth * 24),
        right: 16,
        top: 8,
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.only(
                      topRight: const Radius.circular(16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                      topLeft: Radius.circular(depth > 0 ? 16 : 0),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.black87,
                        fontSize: 13,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: '${_displayNameFor(comment)}  ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: comment.message),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 14,
                  children: [
                    Text(
                      comment.createdAt,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 11,
                      ),
                    ),
                    InkWell(
                      onTap: onReplyTap,
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (comment.isEdited)
                      const Text(
                        'Edited',
                        style: TextStyle(color: AppColors.grey, fontSize: 11),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: onLikeTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  children: [
                    Icon(
                      comment.isLikedByMe
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 16,
                      color: comment.isLikedByMe
                          ? AppColors.red
                          : AppColors.grey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${comment.likeCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _avatarFor(PostCommentModel comment) {
    if (comment.authorAvatar != null && comment.authorAvatar!.isNotEmpty) {
      return comment.authorAvatar!;
    }
    return 'https://placehold.co/80x80';
  }

  String _displayNameFor(PostCommentModel comment) {
    final String name = comment.author.trim();
    if (name.isNotEmpty && name.toLowerCase() != 'unknown user') {
      return name;
    }
    return comment.authorUsername?.trim().isNotEmpty == true
        ? comment.authorUsername!.trim()
        : 'Unknown user';
  }

  int get _effectiveDepth => depth.clamp(0, 3);
}
