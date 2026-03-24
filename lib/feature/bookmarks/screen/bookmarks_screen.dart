import 'package:flutter/material.dart';

import '../../../core/common_data/mock_data.dart';
import '../controller/bookmarks_controller.dart';
import '../model/bookmark_item_model.dart';

class BookmarksScreen extends StatelessWidget {
  BookmarksScreen({super.key}) {
    _controller.load();
  }

  final BookmarksController _controller = BookmarksController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: () => _controller.save(
                    BookmarkItemModel(
                      id: MockData.posts[1].id,
                      title: MockData.posts[1].caption,
                      type: BookmarkType.post,
                    ),
                  ),
                  child: const Text('Save post'),
                ),
                FilledButton(
                  onPressed: () => _controller.save(
                    BookmarkItemModel(
                      id: MockData.posts[2].id,
                      title: MockData.posts[2].caption,
                      type: BookmarkType.reel,
                    ),
                  ),
                  child: const Text('Save reel'),
                ),
                FilledButton(
                  onPressed: () => _controller.save(
                    const BookmarkItemModel(
                      id: 'product_1',
                      title: 'Saved product',
                      type: BookmarkType.product,
                    ),
                  ),
                  child: const Text('Save product'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Card(
              child: ListTile(
                leading: Icon(Icons.bookmark_added_outlined),
                title: Text('Saved Posts'),
                subtitle: Text('This section shows other people\'s posts you saved.'),
              ),
            ),
            const SizedBox(height: 12),
            if (_controller.items.isEmpty)
              const Card(
                child: ListTile(
                  title: Text('No bookmarks yet'),
                  subtitle: Text('Save another user\'s post, reel, or product to see it here.'),
                ),
              ),
            ..._controller.items.map(
              (item) {
                final post = MockData.posts.where((p) => p.id == item.id).firstOrNull;
                final author = post == null
                    ? null
                    : MockData.users.where((u) => u.id == post.authorId).firstOrNull;
                return Card(
                  child: ListTile(
                    title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      author == null
                          ? item.type.name
                          : 'Saved from @${author.username} • ${item.type.name}',
                    ),
                    trailing: IconButton(
                      onPressed: () => _controller.remove(item.id),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
