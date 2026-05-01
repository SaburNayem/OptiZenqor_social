import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SavedCollectionTile extends StatelessWidget {
  const SavedCollectionTile({
    super.key,
    required this.title,
    required this.count,
    required this.previews,
    required this.onTap,
  });

  final String title;
  final int count;
  final List<String> previews;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: previews.isEmpty
                  ? Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.collections_bookmark_outlined,
                        color: AppColors.grey,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        children: previews
                            .take(4)
                            .map((String preview) {
                              if (_isVideoPath(preview)) {
                                return Container(
                                  color: AppColors.black87,
                                  child: const Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: AppColors.white,
                                  ),
                                );
                              }
                              if (preview.startsWith('http://') ||
                                  preview.startsWith('https://')) {
                                return Image.network(
                                  preview,
                                  fit: BoxFit.cover,
                                );
                              }
                              return Image.file(
                                File(preview),
                                fit: BoxFit.cover,
                              );
                            })
                            .toList(growable: false),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '$count saved posts',
              style: TextStyle(color: AppColors.grey600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  bool _isVideoPath(String value) {
    final String lower = value.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm');
  }
}
