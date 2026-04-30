import 'package:flutter/material.dart';

import '../../../core/common_widget/empty_state_view.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../stories/screen/story_view_screen.dart';
import '../repository/archive_repository.dart';

class ArchiveStoriesScreen extends StatelessWidget {
  const ArchiveStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArchiveRepository repository = ArchiveRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Story archive')),
      body: FutureBuilder<List<StoryModel>>(
        future: repository.archivedStories(),
        builder:
            (BuildContext context, AsyncSnapshot<List<StoryModel>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final List<StoryModel> stories =
                  snapshot.data ?? const <StoryModel>[];
              if (stories.isEmpty) {
                return const EmptyStateView(
                  title: 'No archived stories',
                  message: 'Archived stories from backend will appear here.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: stories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final StoryModel story = stories[index];
                  final UserModel? author = story.author;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        author?.avatar ?? 'https://placehold.co/80x80',
                      ),
                    ),
                    title: Text(author?.name ?? 'Story'),
                    subtitle: Text(
                      story.text?.trim().isNotEmpty == true
                          ? story.text!.trim()
                          : 'Open archived story',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StoryViewScreen(
                          stories: stories,
                          users: stories
                              .map((StoryModel item) => item.author)
                              .whereType<UserModel>()
                              .toList(growable: false),
                          initialStoryId: story.id,
                        ),
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
