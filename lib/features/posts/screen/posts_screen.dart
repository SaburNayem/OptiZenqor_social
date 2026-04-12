import 'package:flutter/material.dart';

import '../controller/posts_controller.dart';

class PostsScreen extends StatelessWidget {
  PostsScreen({super.key}) {
    _controller.loadDrafts();
  }

  final PostsController _controller = PostsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Drafts')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.drafts.isEmpty) {
            return const Center(child: Text('No drafts yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.drafts.length,
            itemBuilder: (context, index) {
              final draft = _controller.drafts[index];
              return Card(
                child: ListTile(
                  title: Text(draft.title),
                  subtitle: Text(
                    'Saved ${draft.createdAt.toLocal().toString().split('.').first}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _controller.deleteDraft(draft.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
