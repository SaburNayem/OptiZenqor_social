import 'package:flutter/material.dart';

import '../controller/post_detail_controller.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PostDetailController();

    return Scaffold(
      appBar: AppBar(title: const Text('Post Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(controller.detail.caption),
            ),
          ),
          const SizedBox(height: 12),
          Text('Likes: ${controller.detail.likes}'),
          Text('Comments: ${controller.detail.comments}'),
          const SizedBox(height: 16),
          const Text('Comment Thread (placeholder)'),
          const ListTile(title: Text('Great concept!')),
          const ListTile(title: Text('Can you share the design stack?')),
          const Divider(),
          const Text('Related content (placeholder)'),
        ],
      ),
    );
  }
}
