import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../model/post_comment_model.dart';
import 'post_comment_tile.dart';

class PostCommentThread extends StatelessWidget {
  const PostCommentThread({
    super.key,
    required this.comments,
    required this.onReplyTap,
    required this.onLikeTap,
  });

  final List<PostCommentModel> comments;
  final ValueChanged<PostCommentModel> onReplyTap;
  final ValueChanged<String> onLikeTap;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tiles = _buildBranch(parentId: null, depth: 0);
    if (tiles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          'No comments yet. Start the conversation.',
          style: TextStyle(color: AppColors.grey600),
        ),
      );
    }
    return Column(children: tiles);
  }

  List<Widget> _buildBranch({required String? parentId, required int depth}) {
    final List<PostCommentModel> currentLevel = comments
        .where((PostCommentModel item) => item.replyTo == parentId)
        .toList(growable: false);
    final List<Widget> tiles = <Widget>[];

    for (final PostCommentModel comment in currentLevel) {
      tiles.add(
        PostCommentTile(
          comment: comment,
          depth: depth,
          onLikeTap: () => onLikeTap(comment.id),
          onReplyTap: () => onReplyTap(comment),
        ),
      );
      tiles.addAll(_buildBranch(parentId: comment.id, depth: depth + 1));
    }

    return tiles;
  }
}
