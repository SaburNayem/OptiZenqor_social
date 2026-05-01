import 'package:flutter/material.dart';

import '../../saved_collections/screen/saved_collections_screen.dart';
import 'archive_posts_screen.dart';
import 'archive_reels_screen.dart';
import 'archive_stories_screen.dart';

class ArchiveCenterScreen extends StatelessWidget {
  const ArchiveCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                ListTile(
                  leading: const Icon(Icons.archive_outlined),
                  title: const Text('Archived posts'),
                  subtitle: const Text('Open post archive from backend.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openHiddenPosts(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: const Text('Archived reels'),
                  subtitle: const Text('Open reel archive from backend'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openReelsArchive(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.auto_stories_outlined),
                  title: const Text('Story archive'),
                  subtitle: const Text('Open story archive from backend'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openStoriesArchive(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.collections_bookmark_outlined),
                  title: const Text('Archived collections and boards'),
                  subtitle: const Text('Open your saved collections archive'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openCollectionsArchive(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openHiddenPosts(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ArchivePostsScreen()));
  }

  void _openReelsArchive(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ArchiveReelsScreen()));
  }

  void _openStoriesArchive(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ArchiveStoriesScreen()),
    );
  }

  void _openCollectionsArchive(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SavedCollectionsScreen()),
    );
  }
}
