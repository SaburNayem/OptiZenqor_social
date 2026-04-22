import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/helpers/format_helper.dart';
import '../controller/post_detail_controller.dart';
import 'post_detail_media_section.dart';

class PostDetailContent extends StatelessWidget {
  const PostDetailContent({
    super.key,
    required this.controller,
    required this.author,
    required this.isBookmarked,
    required this.commentTiles,
    required this.onMediaTap,
    required this.onLikeTap,
    required this.onLikeCountTap,
    required this.onCommentTap,
    required this.onShareTap,
    required this.onBookmarkTap,
  });

  final PostDetailController controller;
  final UserModel? author;
  final bool isBookmarked;
  final List<Widget> commentTiles;
  final ValueChanged<int> onMediaTap;
  final VoidCallback onLikeTap;
  final VoidCallback onLikeCountTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          if (author != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(author!.avatar),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          FormatHelper.timeAgo(controller.detail.createdAt),
                          style: TextStyle(
                            color: AppColors.grey500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (controller.detail.media.isNotEmpty)
            PostDetailMediaSection(
              media: controller.detail.media,
              onMediaTap: onMediaTap,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    controller.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        controller.isLiked ? AppColors.red : AppColors.black87,
                  ),
                  onPressed: onLikeTap,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.black87,
                  ),
                  onPressed: onCommentTap,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: AppColors.black87,
                  ),
                  onPressed: onShareTap,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: AppColors.black87,
                  ),
                  onPressed: onBookmarkTap,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onLikeCountTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${FormatHelper.formatCompactNumber(controller.detail.likes)} likes',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.black87,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: '@${author?.username ?? 'user'}  ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: controller.detail.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              'Comments (${controller.comments.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ...commentTiles,
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
