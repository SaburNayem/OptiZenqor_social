import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../model/bookmark_item_model.dart';

class SavedPostListCard extends StatelessWidget {
  const SavedPostListCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onMoreTap,
  });

  final BookmarkItemModel item;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.grey200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SavedPostThumbnail(item: item),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.caption.isEmpty ? item.displayTitle : item.caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.grey700,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMoreTap,
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedPostThumbnail extends StatelessWidget {
  const _SavedPostThumbnail({required this.item});

  final BookmarkItemModel item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 84,
        height: 84,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _thumbnailContent(),
            if (item.isVideo)
              Container(
                color: AppColors.black.withValues(alpha: 0.22),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailContent() {
    if (item.thumbnail.isEmpty) {
      return Container(
        color: AppColors.grey100,
        child: const Icon(Icons.image_not_supported_outlined),
      );
    }
    if (item.isVideo) {
      return Container(
        color: AppColors.black87,
        child: const Icon(Icons.videocam_outlined, color: AppColors.white),
      );
    }
    if (item.thumbnail.startsWith('http://') ||
        item.thumbnail.startsWith('https://')) {
      return Image.network(item.thumbnail, fit: BoxFit.cover);
    }
    return Image.file(File(item.thumbnail), fit: BoxFit.cover);
  }
}
