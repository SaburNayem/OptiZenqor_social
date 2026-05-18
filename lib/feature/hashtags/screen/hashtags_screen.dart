import 'package:flutter/material.dart';

import '../../../core/widgets/error_state_view.dart';
import '../controller/hashtags_controller.dart';

class HashtagsScreen extends StatefulWidget {
  const HashtagsScreen({super.key});

  @override
  State<HashtagsScreen> createState() => _HashtagsScreenState();
}

class _HashtagsScreenState extends State<HashtagsScreen> {
  late final HashtagsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HashtagsController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hashtags')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.errorMessage != null) {
            return ErrorStateView(
              message: _controller.errorMessage!,
              onRetry: _controller.load,
              onRefresh: _controller.load,
            );
          }
          return RefreshIndicator(
            onRefresh: _controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                TextField(
                  onChanged: _controller.search,
                  decoration: const InputDecoration(hintText: 'Search hashtag'),
                ),
                const SizedBox(height: 8),
                if (_controller.visible.isEmpty)
                  const Card(
                    child: ListTile(title: Text('No hashtags available yet')),
                  ),
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
          );
        },
      ),
    );
  }
}
