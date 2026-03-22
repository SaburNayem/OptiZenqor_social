import 'package:get/get.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/post_model.dart';
import '../model/post_detail_model.dart';
import '../model/post_comment_model.dart';

class PostDetailController extends GetxController {
  PostDetailController();

  late PostDetailModel detail;
  final List<PostCommentModel> comments = <PostCommentModel>[];
  List<PostModel> relatedPosts = <PostModel>[];
  bool isLiked = false;

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
          ),
          const PostCommentModel(
            id: 'c2',
            author: 'rafiahmed',
            message: 'Can you share this component breakdown?',
            createdAt: '1h',
          ),
          const PostCommentModel(
            id: 'c3',
            author: 'mayaquinn',
            message: 'Sure, I will post the structure tonight.',
            replyTo: 'c2',
            createdAt: '58m',
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
}
