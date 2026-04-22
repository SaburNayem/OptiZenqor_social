import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/common_widget/inline_video_player.dart';
import '../../../core/constants/app_colors.dart';

class CreatePostMediaPreview extends StatelessWidget {
  const CreatePostMediaPreview({
    super.key,
    required this.mediaPaths,
    required this.hasAnyVideo,
    required this.isVideoPath,
    required this.onReplaceTap,
    required this.onRemoveTap,
  });

  final List<String> mediaPaths;
  final bool hasAnyVideo;
  final bool Function(String path) isVideoPath;
  final VoidCallback onReplaceTap;
  final VoidCallback onRemoveTap;

  @override
  Widget build(BuildContext context) {
    if (mediaPaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: AppColors.black,
        child: Stack(
          children: [
            SizedBox(
              height: 320,
              child: PageView.builder(
                itemCount: mediaPaths.length,
                itemBuilder: (context, index) {
                  final String path = mediaPaths[index];
                  return AspectRatio(
                    aspectRatio: 1,
                    child: isVideoPath(path)
                        ? InlineVideoPlayer(filePath: path, autoPlay: false)
                        : Image.file(File(path), fit: BoxFit.cover),
                  );
                },
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                children: [
                  _CreatePostMediaActionChip(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Replace',
                    onTap: onReplaceTap,
                  ),
                  const SizedBox(width: 8),
                  _CreatePostMediaActionChip(
                    icon: Icons.close_rounded,
                    label: 'Remove',
                    onTap: onRemoveTap,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  hasAnyVideo
                      ? '${mediaPaths.length} media selected'
                      : '${mediaPaths.length} photo selected',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (mediaPaths.length > 1)
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${mediaPaths.length} items',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CreatePostMediaActionChip extends StatelessWidget {
  const _CreatePostMediaActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
