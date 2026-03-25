import 'package:flutter/material.dart';

import '../../../core/data/mock/mock_data.dart';

class ArchiveCenterScreen extends StatelessWidget {
  const ArchiveCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final archivedPosts = MockData.posts
        .where((item) => item.authorId == 'u1')
        .take(2)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My Archive')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.tertiaryContainer,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Archive Center',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'All archived content and hidden history in one place inside settings.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.archive_outlined),
                  title: Text('Archived posts'),
                  subtitle: Text('Posts hidden from your profile appear here.'),
                ),
                const Divider(height: 1),
                ...archivedPosts.map(
                  (post) => ListTile(
                    leading: const Icon(Icons.hide_source_outlined),
                    title: Text(
                      post.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: const Text('Hidden from your profile'),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.play_circle_outline),
                  title: Text('Archived reels'),
                  subtitle: Text('Reel archive placeholder'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.auto_stories_outlined),
                  title: Text('Story archive'),
                  subtitle: Text('Stories, memories, and restored highlights'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.collections_bookmark_outlined),
                  title: Text('Archived collections and boards'),
                  subtitle: Text('Archive anything placeholder'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
