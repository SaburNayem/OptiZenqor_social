import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class PostDetailCommentComposer extends StatelessWidget {
  const PostDetailCommentComposer({
    super.key,
    required this.avatarUrl,
    required this.commentController,
    required this.focusNode,
    required this.onSubmit,
    this.replyingToAuthor,
    this.onCancelReply,
  });

  final String avatarUrl;
  final TextEditingController commentController;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final String? replyingToAuthor;
  final VoidCallback? onCancelReply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey100)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyingToAuthor != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to @$replyingToAuthor',
                      style: TextStyle(
                        color: AppColors.grey700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onCancelReply,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatarUrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: commentController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.send,
                  color: AppColors.hexFF26C6DA,
                ),
                onPressed: onSubmit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
