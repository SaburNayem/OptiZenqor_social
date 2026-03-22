import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/helpers/format_helper.dart';
import '../controller/post_detail_controller.dart';
import '../model/post_comment_model.dart';

class PostDetailScreen extends StatelessWidget {
  PostDetailScreen({
    super.key,
    this.postId,
  }) {
    _controller.load(postId: postId);
  }

  final String? postId;

  final PostDetailController _controller = Get.put(PostDetailController());
  final TextEditingController _commentController = TextEditingController();
  final ValueNotifier<String?> _replyTo = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostDetailController>(
      builder: (controller) {
        final author = MockData.users
            .where((u) => u.id == controller.detail.authorId)
            .firstOrNull;
        return Scaffold(
          appBar: AppBar(title: const Text('Post Detail')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (author != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundImage: NetworkImage(author.avatar)),
                  title: Text(author.name),
                  subtitle: Text('@${author.username}'),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.detail.caption),
                      if (controller.detail.media.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...controller.detail.media.map((String mediaUrl) {
                          final lower = mediaUrl.toLowerCase();
                          final isVideo =
                              lower.endsWith('.mp4') ||
                              lower.endsWith('.mov') ||
                              lower.endsWith('.webm') ||
                              lower.endsWith('.m4v');
                          if (isVideo) {
                            return Container(
                              height: 210,
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.play_circle_outline_rounded),
                                    SizedBox(width: 8),
                                    Text('Video preview'),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(mediaUrl, fit: BoxFit.cover),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ActionChip(
                    label: Text('Likes ${FormatHelper.formatCompactNumber(controller.detail.likes)}'),
                    avatar: Icon(
                      controller.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                    ),
                    onPressed: controller.toggleLike,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('Comments ${controller.detail.comments}'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Comments', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...controller.comments.map((PostCommentModel comment) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: comment.replyTo == null ? 0 : 18,
                    bottom: 6,
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text('@${comment.author}'),
                      subtitle: Text(comment.message),
                      trailing: Text(comment.createdAt),
                      onTap: () {
                        _replyTo.value = comment.id;
                        _commentController.text = '@${comment.author} ';
                        _commentController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _commentController.text.length),
                        );
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              ValueListenableBuilder<String?>(
                valueListenable: _replyTo,
                builder: (context, replyTo, _) {
                  if (replyTo == null) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    children: [
                      const Icon(Icons.reply_rounded, size: 16),
                      const SizedBox(width: 6),
                      const Expanded(child: Text('Reply mode active')),
                      TextButton(
                        onPressed: () {
                          _replyTo.value = null;
                          _commentController.clear();
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment',
                      ),
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  IconButton(
                    onPressed: _submitComment,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Related Posts', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...controller.relatedPosts.map((post) {
                return Card(
                  child: ListTile(
                    title: Text(post.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${post.likes} likes • ${post.comments} comments'),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _submitComment() {
    final text = _commentController.text;
    if (text.trim().isEmpty) {
      return;
    }
    _controller.addComment(text, replyTo: _replyTo.value);
    _commentController.clear();
    _replyTo.value = null;
  }
}
