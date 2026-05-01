import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';

class ShareSourcePostCard extends StatelessWidget {
  const ShareSourcePostCard({
    super.key,
    required this.post,
    required this.author,
  });

  final PostModel post;
  final UserModel author;

  @override
  Widget build(BuildContext context) {
    final String media = post.media.firstOrNull ?? '';
    final bool isVideo = _isVideoPath(media);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 82,
              height: 82,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildMedia(media),
                  if (isVideo)
                    Container(
                      color: AppColors.black.withValues(alpha: 0.28),
                      child: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sharing @${author.username}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.caption,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.grey700, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(String media) {
    if (media.isEmpty) {
      return Container(
        color: AppColors.grey100,
        child: const Icon(Icons.image_outlined),
      );
    }
    if (_isVideoPath(media)) {
      return Container(
        color: AppColors.black87,
        child: const Icon(Icons.videocam_outlined, color: AppColors.white),
      );
    }
    if (media.startsWith('http://') || media.startsWith('https://')) {
      return Image.network(media, fit: BoxFit.cover);
    }
    return Image.file(File(media), fit: BoxFit.cover);
  }

  bool _isVideoPath(String path) {
    final String lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm');
  }
}
