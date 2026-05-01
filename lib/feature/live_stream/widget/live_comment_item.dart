import 'dart:ui';

import 'package:flutter/material.dart';

import '../model/live_stream_model.dart';
import '../../../core/constants/app_colors.dart';

class LiveCommentItem extends StatelessWidget {
  const LiveCommentItem({
    required this.comment,
    required this.fontScale,
    super.key,
  });

  final LiveCommentModel comment;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(comment.avatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            comment.username,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12 * fontScale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (comment.verified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.hexFF4DD8E8,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.message,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.92),
                        fontSize: 12 * fontScale,
                        height: 1.35,
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
