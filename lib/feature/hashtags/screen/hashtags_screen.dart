import 'package:flutter/material.dart';

import '../controller/hashtags_controller.dart';

class HashtagsScreen extends StatelessWidget {
  HashtagsScreen({super.key}) {
    _controller.load();
  }

  final HashtagsController _controller = HashtagsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hashtags')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              onChanged: _controller.search,
              decoration: const InputDecoration(hintText: 'Search hashtag'),
            ),
            const SizedBox(height: 8),
            ..._controller.visible.map(
              (tag) => Card(
                child: ListTile(
                  title: Text(tag.tag),
                  subtitle: Text('${tag.count} posts'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
