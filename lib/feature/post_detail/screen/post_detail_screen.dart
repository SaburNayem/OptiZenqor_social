import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../app_route/route_names.dart';
import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/user_model.dart';
import '../../bookmarks/controller/bookmarks_controller.dart';
import '../../bookmarks/widget/save_post_collection_sheet.dart';
import '../../media_viewer/controller/media_viewer_controller.dart';
import '../../media_viewer/model/media_viewer_route_arguments.dart';
import '../../share_repost_system/widget/share_post_action_sheet.dart';
import '../controller/post_detail_controller.dart';
import '../model/post_comment_model.dart';
import '../widget/post_detail_comment_composer.dart';
import '../widget/post_comment_thread.dart';
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
    _controller.addComment(_commentController.text, replyTo: _replyToCommentId);
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

  PostModel _detailAsPostModel() {
    final detail = _controller.detail;
    return PostModel(
      id: detail.id,
      authorId: detail.authorId,
      caption: detail.caption,
      tags: const <String>[],
      media: detail.media,
      likes: detail.likes,
      comments: detail.comments,
      createdAt: detail.createdAt,
    );
  }

  UserModel? _authorForDetail() {
    return MockData.users
        .where((user) => user.id == _controller.detail.authorId)
        .firstOrNull;
  }

  Future<void> _sharePost() async {
    final UserModel? author = _authorForDetail();
    if (author == null) {
      return;
    }
    await showSharePostActionSheet(
      context: context,
      post: _detailAsPostModel(),
      author: author,
    );
  }

  Future<void> _handleBookmarkTap({
    required BookmarksController bookmarksController,
  }) async {
    final String postId = _controller.detail.id;
    if (bookmarksController.isSaved(postId)) {
      await bookmarksController.unsave(postId);
      if (!mounted) {
        return;
      }
      AppGet.snackbar('Saved posts', 'Post removed from saved');
      return;
    }

    final author = MockData.users
        .where((user) => user.id == _controller.detail.authorId)
        .firstOrNull;
    if (author == null) {
      return;
    }

    final String? destination = await showSavePostCollectionSheet(
      context: context,
      controller: bookmarksController,
      onSave: (collectionId) => bookmarksController.savePost(
        post: _detailAsPostModel(),
        author: author,
        collectionId: collectionId,
      ),
    );
    if (destination == null || !mounted) {
      return;
    }
    AppGet.snackbar('Saved posts', 'Saved to $destination');
  }

  Future<void> _showMoreActions({
    required BookmarksController bookmarksController,
    required bool isBookmarked,
  }) {
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
                  isBookmarked
                      ? Icons.bookmark_remove_outlined
                      : Icons.bookmark_add_outlined,
                ),
                title: Text(
                  isBookmarked ? 'Remove from saved' : 'Save post',
                ),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _handleBookmarkTap(bookmarksController: bookmarksController);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share post'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _sharePost();
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostDetailController>.value(
      value: _controller,
      child: BlocBuilder<PostDetailController, int>(
        builder: (context, _) {
          final PostDetailController controller = _controller;
          final author = _authorForDetail();
          return BlocBuilder<BookmarksController, BookmarksState>(
            builder: (context, _) {
              final BookmarksController bookmarksController =
                  context.read<BookmarksController>();
              final bool isBookmarked = bookmarksController.isSaved(controller.detail.id);

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
                      icon: const Icon(
                        Icons.more_horiz,
                        color: AppColors.black87,
                      ),
                      onPressed: () => _showMoreActions(
                        bookmarksController: bookmarksController,
                        isBookmarked: isBookmarked,
                      ),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    PostDetailContent(
                      controller: controller,
                      author: author,
                      isBookmarked: isBookmarked,
                      commentTiles: <Widget>[
                        PostCommentThread(
                          comments: controller.comments,
                          onLikeTap: controller.toggleCommentLike,
                          onReplyTap: _startReply,
                        ),
                      ],
                      onMediaTap: (index) => _openMediaViewer(
                        title: author?.name ?? 'Post media',
                        initialIndex: index,
                      ),
                      onLikeTap: controller.toggleLike,
                      onCommentTap: _focusCommentField,
                      onShareTap: _sharePost,
                      onBookmarkTap: () => _handleBookmarkTap(
                        bookmarksController: bookmarksController,
                      ),
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
          );
        },
      ),
    );
  }
}

