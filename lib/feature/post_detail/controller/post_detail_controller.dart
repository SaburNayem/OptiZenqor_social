import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/enums/reaction_type.dart';
import '../repository/post_detail_repository.dart';
import '../model/post_detail_model.dart';
import '../model/post_comment_model.dart';

class PostDetailController extends Cubit<int> {
  PostDetailController({PostDetailRepository? repository})
    : _repository = repository ?? PostDetailRepository(),
      super(0);

  final PostDetailRepository _repository;

  PostDetailModel detail = PostDetailModel(
    id: '',
    authorId: '',
    caption: '',
    media: const <String>[],
    likes: 0,
    comments: 0,
    createdAt: DateTime.now(),
  );
  final List<PostCommentModel> comments = <PostCommentModel>[];
  List<PostModel> relatedPosts = <PostModel>[];
  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  bool isLiked = false;
  UserModel? currentUser;
  final Map<ReactionType, int> postReactions = <ReactionType, int>{};
  ReactionType? selectedReaction;
  bool get isOwnPost =>
      currentUser != null &&
      currentUser!.id.trim().isNotEmpty &&
      currentUser!.id == detail.authorId;

  Future<void> load({String? postId}) async {
    final String selectedPostId = postId?.trim() ?? '';
    if (selectedPostId.isEmpty) {
      errorMessage = 'Post not found.';
      hasLoaded = false;
      isLoading = false;
      _notify();
      return;
    }
    isLoading = true;
    errorMessage = null;
    _notify();
    try {
      final PostDetailLoadResult result = await _repository.fetchPostDetail(
        selectedPostId,
      );
      detail = result.detail;
      comments
        ..clear()
        ..addAll(result.comments);
      relatedPosts = result.relatedPosts;
      isLiked = result.isLiked;
      currentUser = result.currentUser;
      postReactions
        ..clear()
        ..addAll(result.postReactions);
      selectedReaction = result.selectedReaction;
      hasLoaded = true;
      isLoading = false;
      errorMessage = null;
      _notify();
    } catch (_) {
      hasLoaded = false;
      isLoading = false;
      errorMessage = 'Unable to load post details.';
      _notify();
    }
  }

  Future<void> toggleLike() async {
    if (detail.id.isEmpty) {
      return;
    }
    final bool previousLiked = isLiked;
    final int previousLikes = detail.likes;
    isLiked = !isLiked;
    detail = detail.copyWith(
      likes: isLiked ? detail.likes + 1 : (detail.likes - 1).clamp(0, 999999),
    );
    _notify();
    try {
      await _repository.setPostLiked(postId: detail.id, liked: isLiked);
    } catch (_) {
      isLiked = previousLiked;
      detail = detail.copyWith(likes: previousLikes);
      _notify();
    }
  }

  void toggleReaction(ReactionType type) {
    final previous = selectedReaction;
    if (previous == type) {
      postReactions[type] = (postReactions[type] ?? 1) - 1;
      if (postReactions[type]! <= 0) {
        postReactions.remove(type);
      }
      selectedReaction = null;
      _notify();
      return;
    }
    if (previous != null) {
      postReactions[previous] = (postReactions[previous] ?? 1) - 1;
      if (postReactions[previous]! <= 0) {
        postReactions.remove(previous);
      }
    }
    postReactions[type] = (postReactions[type] ?? 0) + 1;
    selectedReaction = type;
    _notify();
  }

  Future<bool> addComment(String text, {String? replyTo}) async {
    final value = text.trim();
    if (value.isEmpty) {
      return false;
    }
    try {
      final PostCommentModel created = await _repository.createComment(
        postId: detail.id,
        message: value,
        replyTo: replyTo,
      );
      comments.add(created);
      detail = detail.copyWith(comments: detail.comments + 1);
      _notify();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleCommentLike(String commentId) async {
    final index = comments.indexWhere((item) => item.id == commentId);
    if (index == -1) {
      return;
    }
    final comment = comments[index];
    final isLiking = !comment.isLikedByMe;
    comments[index] = comment.copyWith(
      isLikedByMe: isLiking,
      likeCount: isLiking ? comment.likeCount + 1 : (comment.likeCount - 1).clamp(0, 999999),
      reactions: <String, int>{
        ...comment.reactions,
        'like': ((comment.reactions['like'] ?? 0) + (isLiking ? 1 : -1)).clamp(0, 999999),
      }..removeWhere((String _, int value) => value <= 0),
    );
    _notify();
    try {
      await _repository.reactToComment(
        postId: detail.id,
        commentId: commentId,
        reaction: 'like',
        active: isLiking,
      );
    } catch (_) {
      comments[index] = comment;
      _notify();
    }
  }

  Future<void> toggleCommentReaction(String commentId, String reaction) async {
    final index = comments.indexWhere((item) => item.id == commentId);
    if (index == -1) {
      return;
    }
    final comment = comments[index];
    final next = Map<String, int>.from(comment.reactions);
    next[reaction] = (next[reaction] ?? 0) + 1;
    comments[index] = comment.copyWith(reactions: next);
    _notify();
    try {
      await _repository.reactToComment(
        postId: detail.id,
        commentId: commentId,
        reaction: reaction,
        active: true,
      );
    } catch (_) {
      comments[index] = comment;
      _notify();
    }
  }

  void editComment({required String commentId, required String message}) {
    final index = comments.indexWhere((item) => item.id == commentId);
    if (index == -1) {
      return;
    }
    final text = message.trim();
    if (text.isEmpty) {
      return;
    }
    comments[index] = comments[index].copyWith(message: text, isEdited: true);
    _notify();
  }

  Future<void> deleteComment(String commentId) async {
    final deletingIds = <String>{commentId};
    bool foundNewChild = true;
    while (foundNewChild) {
      foundNewChild = false;
      for (final comment in comments) {
        if (comment.replyTo != null && deletingIds.contains(comment.replyTo) && !deletingIds.contains(comment.id)) {
          deletingIds.add(comment.id);
          foundNewChild = true;
        }
      }
    }
    final removedCount = comments.where((item) => deletingIds.contains(item.id)).length;
    final List<PostCommentModel> snapshot = List<PostCommentModel>.from(comments);
    comments.removeWhere((item) => deletingIds.contains(item.id));
    detail = detail.copyWith(
      comments: (detail.comments - removedCount).clamp(0, 999999),
    );
    _notify();
    try {
      await _repository.deleteComment(postId: detail.id, commentId: commentId);
    } catch (_) {
      comments
        ..clear()
        ..addAll(snapshot);
      detail = detail.copyWith(comments: snapshot.length);
      _notify();
    }
  }

  void reportComment(String commentId) {
    final index = comments.indexWhere((item) => item.id == commentId);
    if (index == -1) {
      return;
    }
    comments[index] = comments[index].copyWith(isReported: true);
    _notify();
  }

  List<PostCommentModel> childCommentsOf(String? parentId) {
    return comments.where((item) => item.replyTo == parentId).toList();
  }

  Future<void> refresh() => load(postId: detail.id);

  Future<void> editPostCaption(String caption) async {
    final String trimmedCaption = caption.trim();
    if (detail.id.isEmpty || trimmedCaption.isEmpty) {
      return;
    }
    final PostDetailModel previous = detail;
    detail = detail.copyWith(caption: trimmedCaption);
    _notify();
    try {
      final PostDetailModel updated = await _repository.updatePostCaption(
        postId: detail.id,
        caption: trimmedCaption,
      );
      detail = updated.copyWith(author: previous.author ?? updated.author);
      _notify();
    } catch (_) {
      detail = previous;
      _notify();
      rethrow;
    }
  }

  Future<void> deletePost() async {
    if (detail.id.isEmpty) {
      return;
    }
    await _repository.deletePost(detail.id);
  }

  void _notify() => emit(state + 1);
}
