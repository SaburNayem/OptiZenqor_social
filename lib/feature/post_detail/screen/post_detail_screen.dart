import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../app_route/route_names.dart';
import '../../../core/data/mock/mock_data.dart';
import '../../../core/constants/app_colors.dart';
import '../../media_viewer/controller/media_viewer_controller.dart';
import '../../media_viewer/model/media_viewer_route_arguments.dart';
import '../controller/post_detail_controller.dart';
import '../model/post_comment_model.dart';
import '../widget/post_comment_tile.dart';
import '../widget/post_detail_comment_composer.dart';
import '../widget/post_detail_content.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({
    super.key,
    this.postId,
  });

  final String? postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final PostDetailController _controller;
  late final TextEditingController _commentController;
  late final FocusNode _commentFocusNode;
  bool _isBookmarked = false;
  String? _replyToCommentId;
  String? _replyingToAuthor;

  @override
  void initState() {
    super.initState();
    _controller = PostDetailController()..load(postId: widget.postId);
    _commentController = TextEditingController();
    _commentFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.close();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _focusCommentField() {
    _commentFocusNode.requestFocus();
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    AppGet.snackbar(
      'Saved',
      _isBookmarked ? 'Post saved to bookmarks' : 'Post removed from bookmarks',
    );
  }

  void _sharePost() {
    AppGet.snackbar('Share post', 'Static share sheet opened for this post');
  }

  void _startReply(PostCommentModel comment) {
    final String mention = '@${comment.author} ';
    setState(() {
      _replyToCommentId = comment.id;
      _replyingToAuthor = comment.author;
      _commentController.value = TextEditingValue(
        text: mention,
        selection: TextSelection.collapsed(offset: mention.length),
      );
    });
    _focusCommentField();
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _replyingToAuthor = null;
    });
    _commentController.clear();
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) {
      return;
    }
    _controller.addComment(
      _commentController.text,
      replyTo: _replyToCommentId,
    );
    _commentController.clear();
    setState(() {
      _replyToCommentId = null;
      _replyingToAuthor = null;
    });
  }

  void _openMediaViewer({required String title, required int initialIndex}) {
    AppGet.toNamed(
      RouteNames.mediaViewer,
      arguments: MediaViewerRouteArguments(
        items: MediaViewerController.fromSources(_controller.detail.media),
        initialIndex: initialIndex,
        title: title,
      ),
    );
  }

  Future<void> _showMoreActions() {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _isBookmarked
                      ? Icons.bookmark_remove_outlined
                      : Icons.bookmark_add_outlined,
                ),
                title: Text(
                  _isBookmarked ? 'Remove from saved' : 'Save post',
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _toggleBookmark();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share post'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _sharePost();
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Report post'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  AppGet.snackbar('Reported', 'Static report flow opened');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCommentTiles(PostDetailController controller) {
    final List<Widget> tiles = <Widget>[];
    final List<PostCommentModel> roots = controller.childCommentsOf(null);

    for (final PostCommentModel comment in roots) {
      tiles.add(
        PostCommentTile(
          comment: comment,
          isReply: false,
          onLikeTap: () => controller.toggleCommentLike(comment.id),
          onReplyTap: () => _startReply(comment),
        ),
      );

      final List<PostCommentModel> replies = controller.childCommentsOf(
        comment.id,
      );
      for (final PostCommentModel reply in replies) {
        tiles.add(
          PostCommentTile(
            comment: reply,
            isReply: true,
            onLikeTap: () => controller.toggleCommentLike(reply.id),
            onReplyTap: () => _startReply(reply),
          ),
        );
      }
    }

    if (tiles.isEmpty) {
      tiles.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'No comments yet. Start the conversation.',
            style: TextStyle(color: AppColors.grey600),
          ),
        ),
      );
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostDetailController>.value(
      value: _controller,
      child: BlocBuilder<PostDetailController, int>(
        builder: (context, _) {
          final PostDetailController controller = _controller;
          final author = MockData.users
              .where((user) => user.id == controller.detail.authorId)
              .firstOrNull;

          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.black87),
                onPressed: AppGet.back,
              ),
              title: const Text(''),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: AppColors.black87),
                  onPressed: _showMoreActions,
                ),
              ],
            ),
            body: Column(
              children: [
                PostDetailContent(
                  controller: controller,
                  author: author,
                  isBookmarked: _isBookmarked,
                  commentTiles: _buildCommentTiles(controller),
                  onMediaTap: (index) => _openMediaViewer(
                    title: author?.name ?? 'Post media',
                    initialIndex: index,
                  ),
                  onLikeTap: controller.toggleLike,
                  onCommentTap: _focusCommentField,
                  onShareTap: _sharePost,
                  onBookmarkTap: _toggleBookmark,
                ),
                PostDetailCommentComposer(
                  avatarUrl: MockData.users.first.avatar,
                  commentController: _commentController,
                  focusNode: _commentFocusNode,
                  replyingToAuthor: _replyingToAuthor,
                  onCancelReply: _cancelReply,
                  onSubmit: _submitComment,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

