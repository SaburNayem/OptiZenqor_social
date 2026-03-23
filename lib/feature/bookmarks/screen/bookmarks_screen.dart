import 'package:flutter/material.dart';

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
                    const BookmarkItemModel(
                      id: 'post_1',
                      title: 'Saved post',
                      type: BookmarkType.post,
                    ),
                  ),
                  child: const Text('Save post'),
                ),
                FilledButton(
                  onPressed: () => _controller.save(
                    const BookmarkItemModel(
                      id: 'reel_1',
                      title: 'Saved reel',
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
            if (_controller.items.isEmpty)
              const Card(
                child: ListTile(
                  title: Text('No bookmarks yet'),
                  subtitle: Text('Save a post, reel, or product to see it here.'),
                ),
              ),
            ..._controller.items.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.type.name),
                  trailing: IconButton(
                    onPressed: () => _controller.remove(item.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
