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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostDetailController>(
      builder: (controller) {
        final author = MockData.users
            .where((u) => u.id == controller.detail.authorId)
            .firstOrNull;
        
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Get.back(),
            ),
            title: const Text(''), // Empty title as per screenshot
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.black87),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Author Header
                    if (author != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(author.avatar),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  author.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  FormatHelper.timeAgo(controller.detail.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // Main Image
                    if (controller.detail.media.isNotEmpty)
                      Image.network(
                        controller.detail.media.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),

                    // Actions Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              controller.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: controller.isLiked ? Colors.red : Colors.black87,
                            ),
                            onPressed: controller.toggleLike,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined, color: Colors.black87),
                            onPressed: () {},
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.bookmark_border, color: Colors.black87),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // Likes and Caption
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${FormatHelper.formatCompactNumber(controller.detail.likes)} likes',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black87, height: 1.4),
                              children: [
                                TextSpan(
                                  text: '@${author?.username ?? 'user'}  ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: controller.detail.caption),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#workspace #productivity',
                            style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text(
                        'Comments ( 89 )',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),

                    // Comments List
                    ...controller.childCommentsOf(null).map((comment) {
                      return _CommentTile(comment: comment);
                    }),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom Comment Input
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(MockData.users.first.avatar),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF26C6DA)),
                      onPressed: () {
                        if (_commentController.text.isNotEmpty) {
                          controller.addComment(_commentController.text);
                          _commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final PostCommentModel comment;

  @override
  Widget build(BuildContext context) {
    // Mock user data for comments based on screenshots
    final Map<String, String> avatars = {
      'marcusc': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500',
      'emmaw': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500',
      'dkim': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
    };

    final isReply = comment.author == 'sarahj';

    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 64 : 16,
        right: 16,
        top: 8,
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(avatars[comment.author] ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(0),
                      topRight: const Radius.circular(16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.3),
                      children: [
                        TextSpan(
                          text: '@${comment.author}   ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (isReply)
                          const TextSpan(
                            text: '@sarahj   ',
                            style: TextStyle(color: Color(0xFF00ACC1), fontWeight: FontWeight.bold),
                          ),
                        TextSpan(text: comment.message),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('2h', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(width: 16),
                    const Text('Reply', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          if (!isReply)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  const Icon(Icons.favorite_border, size: 14, color: Colors.grey),
                  const SizedBox(height: 2),
                  Text('${comment.likeCount}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
