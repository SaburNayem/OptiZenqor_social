import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../app_route/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/helpers/format_helper.dart';
import '../../../core/platform/device_settings_service.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../bookmarks/controller/bookmarks_controller.dart';
import '../../bookmarks/widget/save_post_collection_sheet.dart';
import '../../media_viewer/controller/media_viewer_controller.dart';
import '../../media_viewer/model/media_viewer_route_arguments.dart';
import '../../share_repost_system/widget/share_post_action_sheet.dart';
import '../controller/post_detail_controller.dart';
import '../model/post_comment_model.dart';
import '../widget/post_comment_thread.dart';
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
  Timer? _loadingRetryTimer;
  bool _showLoadingRetry = false;
  String? _replyToCommentId;
  String? _replyingToAuthor;

  @override
  void initState() {
    super.initState();
    _controller = PostDetailController();
    _commentController = TextEditingController();
    _commentFocusNode = FocusNode();
    _loadPost();
  }

  @override
  void dispose() {
    _loadingRetryTimer?.cancel();
    _controller.close();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _loadPost() {
    _loadingRetryTimer?.cancel();
    if (_showLoadingRetry) {
      setState(() {
        _showLoadingRetry = false;
      });
    } else {
      _showLoadingRetry = false;
    }
    _loadingRetryTimer = Timer(const Duration(seconds: 30), () {
      if (!mounted || !_controller.isLoading || _controller.hasLoaded) {
        return;
      }
      setState(() {
        _showLoadingRetry = true;
      });
    });
    unawaited(_controller.load(postId: widget.postId));
  }

  Future<void> _openNetworkSettings() async {
    final bool opened = await DeviceSettingsService.openNetworkSettings();
    if (!opened && mounted) {
      AppGet.snackbar('Network settings', 'Unable to open device settings.');
    }
  }

  void _focusCommentField() {
    _commentFocusNode.requestFocus();
  }

  void _startReply(PostCommentModel comment) {
    final String mention = '@${comment.authorUsername ?? comment.author} ';
    setState(() {
      _replyToCommentId = comment.id;
      _replyingToAuthor = comment.authorUsername ?? comment.author;
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

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }
    final bool created = await _controller.addComment(
      _commentController.text,
      replyTo: _replyToCommentId,
    );
    if (!created) {
      return;
    }
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
      shareCount: detail.shareCount,
      viewCount: detail.viewCount,
      author: detail.author,
    );
  }

  UserModel? _authorForDetail() {
    return _controller.detail.author;
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

  Future<void> _editPost() async {
    final TextEditingController textController = TextEditingController(
      text: _controller.detail.caption,
    );
    final String? nextCaption = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit post'),
          content: TextField(
            controller: textController,
            maxLines: 5,
            minLines: 3,
            decoration: const InputDecoration(hintText: 'Write something...'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                textController.text.trim(),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    textController.dispose();
    if (nextCaption == null || nextCaption.trim().isEmpty || !mounted) {
      return;
    }
    try {
      await _controller.editPostCaption(nextCaption);
      if (!mounted) {
        return;
      }
      AppGet.snackbar('Post', 'Post updated');
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppGet.snackbar(
        'Post',
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _deletePost() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete post?'),
          content: const Text('This post will be removed permanently.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await _controller.deletePost();
      if (!mounted) {
        return;
      }
      AppGet.back();
      AppGet.snackbar('Post', 'Post deleted');
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppGet.snackbar(
        'Post',
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _showLikesSheet() {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Likes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${FormatHelper.formatCompactNumber(_controller.detail.likes)} people reacted to this post',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(
                  height: 80,
                  child: Center(
                    child: Text('Detailed reaction users are not available yet'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleBookmarkTap({
    required BookmarksController? bookmarksController,
  }) async {
    if (bookmarksController == null) {
      AppGet.snackbar('Saved posts', 'Save is unavailable right now.');
      return;
    }

    final String postId = _controller.detail.id;
    if (postId.trim().isEmpty) {
      AppGet.snackbar('Saved posts', 'Post details are still loading.');
      return;
    }

    if (bookmarksController.isSaved(postId)) {
      try {
        await bookmarksController.unsave(postId);
        if (!mounted) {
          return;
        }
        AppGet.snackbar('Saved posts', 'Post removed from saved');
      } catch (_) {
        if (!mounted) {
          return;
        }
        AppGet.snackbar('Saved posts', 'Unable to update saved posts.');
      }
      return;
    }

    final UserModel? author = _authorForDetail();
    if (author == null) {
      AppGet.snackbar('Saved posts', 'Author details are still loading.');
      return;
    }

    try {
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
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppGet.snackbar('Saved posts', 'Unable to save this post right now.');
    }
  }

  Future<void> _showMoreActions({
    required BookmarksController? bookmarksController,
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
                  if (!isBookmarked) {
                    await Future<void>.delayed(
                      const Duration(milliseconds: 220),
                    );
                    if (!mounted) {
                      return;
                    }
                  }
                  await _handleBookmarkTap(
                    bookmarksController: bookmarksController,
                  );
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
              if (_controller.isOwnPost)
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit post'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _editPost();
                  },
                ),
              if (_controller.isOwnPost)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text('Delete post'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _deletePost();
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
          final UserModel? author = _authorForDetail();
          if (!controller.isLoading &&
              !controller.hasLoaded &&
              controller.errorMessage != null) {
            _loadingRetryTimer?.cancel();
            return _buildNetworkStateScaffold(
              message: controller.errorMessage!,
              icon: Icons.error_outline_rounded,
            );
          }
          if (controller.isLoading && !controller.hasLoaded) {
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
              ),
              body: _showLoadingRetry
                  ? _PostDetailRetryView(
                      message: 'Post details are taking too long to load.',
                      onRetry: _loadPost,
                      onOpenSettings: _openNetworkSettings,
                    )
                  : const _PostDetailShimmer(),
            );
          }
          _loadingRetryTimer?.cancel();
          final BookmarksController? bookmarksController =
              _bookmarksControllerOf(context);
          if (bookmarksController != null) {
            return BlocBuilder<BookmarksController, BookmarksState>(
              builder: (context, _) => _buildLoadedScaffold(
                controller: controller,
                author: author,
                bookmarksController: bookmarksController,
                isBookmarked: bookmarksController.isSaved(controller.detail.id),
              ),
            );
          }
          return _buildLoadedScaffold(
            controller: controller,
            author: author,
            bookmarksController: null,
            isBookmarked: false,
          );
        },
      ),
    );
  }

  Widget _buildLoadedScaffold({
    required PostDetailController controller,
    required UserModel? author,
    required BookmarksController? bookmarksController,
    required bool isBookmarked,
  }) {
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
            onLikeTap: () => controller.toggleLike(),
            onLikeCountTap: _showLikesSheet,
            onCommentTap: _focusCommentField,
            onShareTap: _sharePost,
            onBookmarkTap: () => _handleBookmarkTap(
              bookmarksController: bookmarksController,
            ),
            onRefresh: controller.refresh,
          ),
          PostDetailCommentComposer(
            avatarUrl:
                controller.currentUser?.avatar.isNotEmpty == true
                ? controller.currentUser!.avatar
                : 'https://placehold.co/80x80',
            commentController: _commentController,
            focusNode: _commentFocusNode,
            replyingToAuthor: _replyingToAuthor,
            onCancelReply: _cancelReply,
            onSubmit: _submitComment,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStateScaffold({
    required String message,
    required IconData icon,
  }) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black87),
          onPressed: AppGet.back,
        ),
      ),
      body: _PostDetailRetryView(
        message: message,
        icon: icon,
        onRetry: _loadPost,
        onOpenSettings: _openNetworkSettings,
      ),
    );
  }

  BookmarksController? _bookmarksControllerOf(BuildContext context) {
    try {
      return BlocProvider.of<BookmarksController>(context);
    } catch (_) {
      return null;
    }
  }
}

class _PostDetailRetryView extends StatelessWidget {
  const _PostDetailRetryView({
    required this.message,
    required this.onRetry,
    required this.onOpenSettings,
    this.icon = Icons.wifi_off_rounded,
  });

  final String message;
  final IconData icon;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check Wi-Fi or mobile data, then try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  label: const Text('Network settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostDetailShimmer extends StatelessWidget {
  const _PostDetailShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          Row(
            children: [
              ShimmerBox(height: 40, width: 40, radius: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(height: 14, width: 140),
                    SizedBox(height: 8),
                    ShimmerBox(height: 12, width: 80),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ShimmerBox(height: 320, radius: 20),
          SizedBox(height: 16),
          ShimmerBox(height: 18, width: 90),
          SizedBox(height: 10),
          ShimmerBox(height: 12),
          SizedBox(height: 8),
          ShimmerBox(height: 12, width: 240),
          SizedBox(height: 24),
          ShimmerBox(height: 16, width: 120),
          SizedBox(height: 12),
          ShimmerBox(height: 72, radius: 16),
          SizedBox(height: 12),
          ShimmerBox(height: 72, radius: 16),
        ],
      ),
    );
  }
}
