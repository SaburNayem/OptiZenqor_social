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

    final title = switch ((mediaPaths.length, hasAnyVideo)) {
      (1, true) => '1 video selected',
      (1, false) => '1 photo selected',
      (_, true) => '${mediaPaths.length} media selected',
      _ => '${mediaPaths.length} photos selected',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.black87,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onReplaceTap,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: Text(mediaPaths.length > 1 ? 'Add more' : 'Replace'),
              ),
              IconButton(
                tooltip: 'Remove media',
                onPressed: onRemoveTap,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (mediaPaths.length == 1)
            _CreatePostMediaTile(
              path: mediaPaths.first,
              isVideo: isVideoPath(mediaPaths.first),
              wide: true,
            )
          else
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mediaPaths.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final path = mediaPaths[index];
                  return _CreatePostMediaTile(
                    path: path,
                    isVideo: isVideoPath(path),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CreatePostMediaTile extends StatelessWidget {
  const _CreatePostMediaTile({
    required this.path,
    required this.isVideo,
    this.wide = false,
  });

  final String path;
  final bool isVideo;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isVideo)
            InlineVideoPlayer(filePath: path, autoPlay: false)
          else
            Image.file(File(path), fit: BoxFit.cover),
          if (isVideo)
            Container(
              color: AppColors.black.withValues(alpha: 0.24),
              alignment: Alignment.center,
              child: const Icon(
                Icons.play_circle_fill_rounded,
                color: AppColors.white,
                size: 34,
              ),
            ),
        ],
      ),
    );

    if (wide) {
      return AspectRatio(aspectRatio: 1.5, child: child);
    }

    return SizedBox(width: 122, child: child);
  }
}
