import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/enums/reaction_type.dart';
import '../../../core/helpers/format_helper.dart';
import '../../../core/widgets/inline_video_player.dart';
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
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 230,
                                child: InlineVideoPlayer(networkUrl: mediaUrl),
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReactionType.values.map((type) {
                  final count = controller.postReactions[type] ?? 0;
                  final selected = controller.selectedReaction == type;
                  return FilterChip(
                    selected: selected,
                    label: Text('${type.emoji} $count'),
                    onSelected: (_) => controller.toggleReaction(type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Comments', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...controller.childCommentsOf(null).map((comment) {
                return _CommentThreadTile(
                  comment: comment,
                  children: controller.childCommentsOf(comment.id),
                  childrenResolver: controller.childCommentsOf,
                  onReply: (PostCommentModel item) {
                    _replyTo.value = item.id;
                    _commentController.text = '@${item.author} ';
                    _commentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _commentController.text.length),
                    );
                  },
                  onLike: controller.toggleCommentLike,
                  onEdit: (id, message) => controller.editComment(commentId: id, message: message),
                  onDelete: controller.deleteComment,
                  onReport: controller.reportComment,
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

class _CommentThreadTile extends StatelessWidget {
  const _CommentThreadTile({
    required this.comment,
    required this.children,
    required this.childrenResolver,
    required this.onReply,
    required this.onLike,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
    this.depth = 0,
  });

  final PostCommentModel comment;
  final List<PostCommentModel> children;
  final List<PostCommentModel> Function(String? parentId) childrenResolver;
  final void Function(PostCommentModel comment) onReply;
  final void Function(String id) onLike;
  final void Function(String id, String message) onEdit;
  final void Function(String id) onDelete;
  final void Function(String id) onReport;
  final int depth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, bottom: 6),
      child: Column(
        children: [
          Card(
            child: ListTile(
              title: Row(
                children: [
                  Expanded(child: Text('@${comment.author}')),
                  if (comment.isReported)
                    const Icon(Icons.flag_rounded, size: 16),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.message),
                  if (comment.isEdited)
                    Text(
                      'edited',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      ActionChip(
                        label: Text(comment.isLikedByMe ? 'Unlike ${comment.likeCount}' : 'Like ${comment.likeCount}'),
                        onPressed: () => onLike(comment.id),
                      ),
                      ActionChip(
                        label: const Text('Reply'),
                        onPressed: () => onReply(comment),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    final controller = TextEditingController(text: comment.message);
                    final updated = await showDialog<String>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Edit comment'),
                          content: TextField(controller: controller, maxLines: 3),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                    if (updated != null) {
                      onEdit(comment.id, updated);
                    }
                    return;
                  }
                  if (value == 'delete') {
                    onDelete(comment.id);
                    return;
                  }
                  if (value == 'report') {
                    onReport(comment.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                  PopupMenuItem(value: 'report', child: Text('Report')),
                ],
              ),
            ),
          ),
          ...children.map((item) {
            return _CommentThreadTile(
              comment: item,
              children: childrenResolver(item.id),
              childrenResolver: childrenResolver,
              depth: depth + 1,
              onReply: onReply,
              onLike: onLike,
              onEdit: onEdit,
              onDelete: onDelete,
              onReport: onReport,
            );
          }),
        ],
      ),
    );
  }
}
