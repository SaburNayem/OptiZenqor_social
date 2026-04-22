import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CreatePostComposerCard extends StatelessWidget {
  const CreatePostComposerCard({
    super.key,
    required this.avatarUrl,
    required this.userName,
    required this.audience,
    required this.captionController,
    required this.onAudienceTap,
    this.attachmentPreview,
  });

  final String avatarUrl;
  final String userName;
  final String audience;
  final TextEditingController captionController;
  final VoidCallback onAudienceTap;
  final Widget? attachmentPreview;

  @override
  Widget build(BuildContext context) {
    final hasAttachment = attachmentPreview != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: onAudienceTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.public_rounded,
                              size: 14,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              audience,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: AppColors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: captionController,
            minLines: hasAttachment ? 4 : 5,
            maxLines: 8,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              hintText: "What's on your mind?",
              hintStyle: TextStyle(
                color: AppColors.grey,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (attachmentPreview != null) ...[
            const SizedBox(height: 14),
            attachmentPreview!,
          ],
        ],
      ),
    );
  }
}
