import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CreatePostBottomToolbar extends StatelessWidget {
  const CreatePostBottomToolbar({
    super.key,
    required this.captionLength,
    required this.onMediaTap,
    required this.onTagTap,
    required this.onFeelingTap,
  });

  final int captionLength;
  final VoidCallback onMediaTap;
  final VoidCallback onTagTap;
  final VoidCallback onFeelingTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey100)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.hexFF26C6DA,
            ),
            onPressed: onMediaTap,
          ),
          IconButton(
            icon: const Icon(Icons.tag, color: AppColors.hexFF26C6DA),
            onPressed: onTagTap,
          ),
          IconButton(
            icon: const Icon(
              Icons.sentiment_satisfied_alt_outlined,
              color: AppColors.hexFF26C6DA,
            ),
            onPressed: onFeelingTap,
          ),
          const Spacer(),
          Text(
            '$captionLength / 280',
            style: const TextStyle(color: AppColors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
