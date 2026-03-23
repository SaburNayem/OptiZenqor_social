import 'package:get/get.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/post_model.dart';
import '../../../core/enums/reaction_type.dart';
import '../model/post_detail_model.dart';
import '../model/post_comment_model.dart';

class PostDetailController extends GetxController {
  PostDetailController();

  late PostDetailModel detail;
  final List<PostCommentModel> comments = <PostCommentModel>[];
  List<PostModel> relatedPosts = <PostModel>[];
  bool isLiked = false;
  final Map<ReactionType, int> postReactions = <ReactionType, int>{
    ReactionType.like: 18,
    ReactionType.love: 7,
    ReactionType.haha: 3,
  };
  ReactionType? selectedReaction;

  void load({String? postId}) {
    final selected = MockData.posts.where((p) => p.id == postId).firstOrNull ?? MockData.posts.first;
    detail = PostDetailModel(
      id: selected.id,
      authorId: selected.authorId,
      caption: selected.caption,
      media: selected.media,
      likes: selected.likes,
      comments: selected.comments,
    );
    comments
      ..clear()
      ..addAll(
        <PostCommentModel>[
          const PostCommentModel(
            id: 'c1',
            author: 'nexa.studio',
            message: 'The visual style is super clean.',
            createdAt: '2h',
            likeCount: 4,
            reactions: <String, int>{'love': 2},
          ),
          const PostCommentModel(
            id: 'c2',
            author: 'rafiahmed',
            message: 'Can you share this component breakdown? @mayaquinn',
            createdAt: '1h',
            likeCount: 2,
            mentions: <String>['mayaquinn'],
            reactions: <String, int>{'insightful': 1},
          ),
          const PostCommentModel(
            id: 'c3',
            author: 'mayaquinn',
            message: 'Sure, I will post the structure tonight.',
            replyTo: 'c2',
            createdAt: '58m',
            likeCount: 1,
          ),
        ],
      );

    relatedPosts = MockData.posts
        .where((p) => p.id != detail.id)
        .take(3)
        .toList();
    update();
  }

  void toggleLike() {
    isLiked = !isLiked;
    detail = PostDetailModel(
      id: detail.id,
      authorId: detail.authorId,
      caption: detail.caption,
      media: detail.media,
      likes: isLiked ? detail.likes + 1 : detail.likes - 1,
      comments: detail.comments,
    );
    update();
  }

  void toggleReaction(ReactionType type) {
    final previous = selectedReaction;
    if (previous == type) {
      postReactions[type] = (postReactions[type] ?? 1) - 1;
      if (postReactions[type]! <= 0) {
        postReactions.remove(type);
      }
      selectedReaction = null;
      update();
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
    update();
  }

  void addComment(String text, {String? replyTo}) {
    final value = text.trim();
    if (value.isEmpty) {
      return;
    }
    comments.add(
      PostCommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        author: 'you',
        message: value,
        replyTo: replyTo,
        createdAt: 'now',
        likeCount: 0,
        mentions: RegExp(r'@([a-zA-Z0-9_.]+)')
            .allMatches(value)
            .map((item) => item.group(1) ?? '')
            .where((item) => item.isNotEmpty)
            .toList(),
      ),
    );
    detail = PostDetailModel(
      id: detail.id,
      authorId: detail.authorId,
      caption: detail.caption,
      media: detail.media,
      likes: detail.likes,
      comments: detail.comments + 1,
    );
    update();
  }

  void toggleCommentLike(String commentId) {
    final index = comments.indexWhere((item) => item.id == commentId);
    if (index == -1) {
      return;
    }
    final comment = comments[index];
    final isLiking = !comment.isLikedByMe;
    comments[index] = comment.copyWith(
      isLikedByMe: isLiking,
      likeCount: isLiking ? comment.likeCount + 1 : (comment.likeCount - 1).clamp(0, 999999),
    );
    update();
  }

  void toggleCommentReaction(String commentId, String reaction) {
    final index = comments.indexWhere((item) => item.id == commentId);
    if (index == -1) {
      return;
    }
    final comment = comments[index];
    final next = Map<String, int>.from(comment.reactions);
    next[reaction] = (next[reaction] ?? 0) + 1;
    comments[index] = comment.copyWith(reactions: next);
    update();
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
    update();
  }

  void deleteComment(String commentId) {
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
    comments.removeWhere((item) => deletingIds.contains(item.id));
    detail = PostDetailModel(
      id: detail.id,
      authorId: detail.authorId,
      caption: detail.caption,
      media: detail.media,
      likes: detail.likes,
      comments: (detail.comments - removedCount).clamp(0, 999999),
    );
    update();
  }

  void reportComment(String commentId) {
    final index = comments.indexWhere((item) => item.id == commentId);
    if (index == -1) {
      return;
    }
    comments[index] = comments[index].copyWith(isReported: true);
    update();
  }

  List<PostCommentModel> childCommentsOf(String? parentId) {
    return comments.where((item) => item.replyTo == parentId).toList();
  }
}
